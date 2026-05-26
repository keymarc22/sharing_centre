class CalendarsController < ApplicationController
  include CalendarAuthenticationConcern

  before_action :authenticate_user!
  before_action :set_class_session, only: [:update, :destroy]

  def new
    @class_session = ClassSession.new
    if params[:date]
      date = Date.parse(params[:date]) rescue Date.today
      @class_session.start_at = date.beginning_of_day + 9.hours
      @class_session.end_at = date.beginning_of_day + 10.hours
    end
  end

  def index
    @calendar_date = parse_date_param
    range = @calendar_date.beginning_of_month..@calendar_date.end_of_month
    @class_sessions = sessions_for_range(filtered_sessions, range)

    respond_to do |format|
      format.html
      format.json { render json: serialize_sessions(@class_sessions, range) }
    end
  end

  def navigate
    @calendar_date = parse_date_param
    range = @calendar_date.beginning_of_month..@calendar_date.end_of_month
    @class_sessions = sessions_for_range(filtered_sessions, range)
    render layout: false
  end

  def create
    recurrence_rule = build_recurrence_rule
    @class_session = ClassSession.new(session_params.merge(recurrence_rule: recurrence_rule))
    authorize_action!

    if @class_session.save
      if recurrence_rule.present?
        @class_session.update_recurrence_ends_at!
      end
      if creator_connected?
        create_google_event(@class_session)
      end
      render json: @class_session, status: :created
    else
      render json: @class_session.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize_action!
    if @class_session.update(session_params)
      if @class_session.google_event_id.present? && creator_connected?
        update_google_event(@class_session)
      end
      render json: @class_session
    else
      render json: @class_session.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_action!
    if @class_session.google_event_id.present? && creator_connected?
      delete_google_event(@class_session)
    end
    @class_session.destroy
    head :no_content
  end

  def sync
    time_min = Date.today.beginning_of_month.to_datetime
    time_max = Date.today.end_of_month.to_datetime
    google_events = GoogleCalendarService.new(current_user).list_events(time_min: time_min, time_max: time_max)

    sync_events(google_events)
    render json: { synced: true }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def parse_date_param
    params[:date].present? ? Date.parse(params[:date]) : Date.today
  rescue ArgumentError
    Date.today
  end

  def set_class_session
    @class_session = ClassSession.find(params[:id])
  end

  def session_params
    params.require(:class_session).permit(:title, :description, :start_at, :end_at, :teacher_id, :student_id, :time_zone, :meet_link)
  end

  def recurrence_params
    params.permit(:recurrence_frequency, :recurrence_count, :recurrence_until)
  end

  def build_recurrence_rule
    freq = recurrence_params[:recurrence_frequency]
    return nil if freq.blank? || freq == 'none'

    interval = freq == 'biweekly' ? ';INTERVAL=2' : ''
    count = recurrence_params[:recurrence_count].presence
    until_date = recurrence_params[:recurrence_until].presence

    if until_date.present?
      "RRULE:FREQ=WEEKLY#{interval};UNTIL=#{Date.parse(until_date).strftime('%Y%m%dT235959Z')}"
    elsif count.present? && count.to_i > 0
      "RRULE:FREQ=WEEKLY#{interval};COUNT=#{count.to_i}"
    else
      "RRULE:FREQ=WEEKLY#{interval};COUNT=10"
    end
  rescue ArgumentError
    nil
  end

  def filtered_sessions
    if current_user.admin?
      if params[:teacher_id]
        ClassSession.where(teacher_id: params[:teacher_id])
      elsif params[:student_id]
        ClassSession.where(student_id: params[:student_id])
      else
        ClassSession.all
      end
    elsif current_user.teacher?
      ClassSession.where(teacher_id: current_user.id)
    else
      ClassSession.where(student_id: current_user.id)
    end
  end

  def sessions_for_range(base_scope, range)
    non_recurring = base_scope.where(recurrence_rule: nil).where(start_at: range)
    recurring = base_scope.where.not(recurrence_rule: nil)
                          .where(start_at: ..range.last)
                          .where('recurrence_ends_at IS NULL OR recurrence_ends_at >= ?', range.first)
    (non_recurring + recurring).uniq(&:id)
  end

  def authorize_action!
    if current_user.admin?
      return
    elsif current_user.teacher?
      teacher_id = @class_session&.teacher_id || session_params[:teacher_id].to_i
      return if teacher_id == current_user.id
      render json: { error: 'Not authorized' }, status: :forbidden
    else
      return if @class_session.student_id == current_user.id
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def creator_connected?
    current_user.google_connected?
  end

  def create_google_event(class_session)
    service = GoogleCalendarService.new(current_user)
    google_event = service.create_event(map_to_google_event(class_session))
    class_session.update(
      google_event_id: google_event.id,
      meet_link: extract_meet_link(google_event),
      google_calendar_owner_id: current_user.id
    )
  rescue StandardError => e
    Rails.logger.warn("Failed to create Google Calendar event: #{e.message}")
  end

  def update_google_event(class_session)
    owner = User.find_by(id: class_session.google_calendar_owner_id) || class_session.teacher
    return unless owner.google_connected?

    service = GoogleCalendarService.new(owner)
    google_event = service.update_event(class_session.google_event_id, map_to_google_event(class_session))
    class_session.update(meet_link: extract_meet_link(google_event))
  rescue StandardError => e
    Rails.logger.warn("Failed to update Google Calendar event: #{e.message}")
  end

  def extract_meet_link(google_event)
    google_event.conference_data&.entry_points&.find { |ep| ep.entry_point_type == 'video' }&.uri ||
      google_event.hangout_link
  end

  def delete_google_event(class_session)
    owner = User.find_by(id: class_session.google_calendar_owner_id) || class_session.teacher
    return unless owner.google_connected?

    service = GoogleCalendarService.new(owner)
    service.delete_event(class_session.google_event_id)
  rescue StandardError => e
    Rails.logger.warn("Failed to delete Google Calendar event: #{e.message}")
  end

  def map_to_google_event(class_session)
    event = {
      summary: class_session.title,
      description: class_session.description,
      start: { date_time: class_session.start_at.iso8601, time_zone: class_session.time_zone || 'UTC' },
      end: { date_time: class_session.end_at.iso8601, time_zone: class_session.time_zone || 'UTC' },
      attendees: [class_session.student&.email, class_session.teacher&.email].compact.map { |email| { email: email } },
      conference_data: {
        create_request: {
          request_id: SecureRandom.uuid,
          conference_solution_key: { type: 'hangoutsMeet' }
        }
      }
    }
    event[:recurrence] = [class_session.recurrence_rule] if class_session.recurring?
    event
  end

  def sync_events(google_events)
    google_event_ids = Set.new(google_events.map(&:id))
    local_event_ids = ClassSession.where(google_calendar_owner_id: current_user.id).pluck(:google_event_id).compact

    # Delete local events that no longer exist in Google
    (local_event_ids - google_event_ids.to_a).each do |event_id|
      ClassSession.find_by(google_event_id: event_id)&.destroy
    end

    # Create or update events from Google
    google_events.each do |google_event|
      next if google_event.summary.blank?

      class_session = ClassSession.find_or_initialize_by(google_event_id: google_event.id)
      class_session.assign_attributes(
        title: google_event.summary,
        description: google_event.description,
        start_at: parse_google_datetime(google_event.start),
        end_at: parse_google_datetime(google_event.end),
        time_zone: google_event.start&.time_zone || 'UTC',
        meet_link: google_event.hangout_link,
        google_calendar_owner_id: current_user.id
      )
      class_session.save if class_session.valid?
    end
  end

  def parse_google_datetime(datetime_obj)
    if datetime_obj.date_time.present?
      datetime_obj.date_time
    elsif datetime_obj.date.present?
      datetime_obj.date.to_datetime
    end
  end

  def serialize_sessions(sessions, range = nil)
    sessions.flat_map do |session|
      if session.recurring? && range
        duration = session.end_at - session.start_at
        session.occurrences_between(range.first.to_time, range.last.to_time).map do |occurrence|
          serialize_session_occurrence(session, occurrence, occurrence + duration)
        end
      else
        [serialize_session_occurrence(session, session.start_at, session.end_at)]
      end
    end
  end

  def serialize_session_occurrence(session, start_time, end_time)
    {
      id: session.id,
      title: session.title,
      start: start_time.iso8601,
      end: end_time.iso8601,
      extendedProps: {
        meet_link: session.meet_link,
        teacher_name: session.teacher.name,
        student_name: session.student.name,
        description: session.description
      }
    }
  end
end
