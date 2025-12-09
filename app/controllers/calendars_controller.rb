class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:update, :destroy, :show]

  def index
    if current_user.admin?
      @events = if params[:teacher_id]
                  Lesson.where(teacher_id: params[:teacher_id])
                elsif params[:student_id]
                  Lesson.where(student_id: params[:student_id])
                else
                  Lesson.all
                end
    elsif current_user.teacher?
      @events = Lesson.where(teacher_id: current_user.id)
    else
      @events = Lesson.where(student_id: current_user.id)
    end

    respond_to do |format|
      format.html
      format.json { render json: @events } # adaptar para FullCalendar
    end
  end

  # Crear evento local y (si el usuario tiene Google conectado) crear en su Google Calendar
  def create
    @event = Lesson.new(event_params)
    authorize_event_action!

    if @event.save
      # si el usuario que crea tiene google conectado, crear evento en Google
      creator = current_user
      if creator.google_connected?
        service = GoogleCalendarService.new(creator)
        g = service.create_event(map_lesson_to_google(@event))
        @event.update(google_event_id: g.id, google_calendar_owner: creator.id)
      end
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # Update local + Google if linked
  def update
    authorize_event_action!
    if @event.update(event_params)
      owner_user = User.find_by(id: @event.google_calendar_owner) || @event.teacher
      if owner_user&.google_connected? && @event.google_event_id.present?
        service = GoogleCalendarService.new(owner_user)
        service.update_event(@event.google_event_id, map_lesson_to_google(@event))
      end
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_event_action!
    owner_user = User.find_by(id: @event.google_calendar_owner) || @event.teacher
    if owner_user&.google_connected? && @event.google_event_id.present?
      service = GoogleCalendarService.new(owner_user)
      service.delete_event(@event.google_event_id) rescue Rails.logger.warn("No pude eliminar evento Google #{@event.google_event_id}")
    end
    @event.destroy
    head :no_content
  end

  private

  def set_event
    @event = Lesson.find(params[:id])
  end

  def event_params
    params.require(:lesson).permit(:title, :description, :start_at, :end_at, :teacher_id, :student_id, :time_zone)
  end

  def map_lesson_to_google(lesson)
    {
      summary: lesson.title || "Clase: #{lesson.id}",
      description: lesson.description,
      start: lesson.start_at,
      end: lesson.end_at,
      time_zone: lesson.time_zone || 'UTC',
      attendees: [lesson.student&.email, lesson.teacher&.email].compact
    }
  end

  # autorizar según rol; ejemplo sencillo (debes adaptar a Pundit/CanCan si usas)
  def authorize_event_action!
    if current_user.admin?
      return
    elsif current_user.teacher?
      # teacher puede manipular sólo sus clases
      unless params[:lesson] && (params[:lesson][:teacher_id].to_i == current_user.id || @event&.teacher_id == current_user.id)
        render json: {error: 'No autorizado'}, status: :forbidden and return
      end
    else
      # student puede ver y editar solo sus propias (quizá solo editar cancelación)
      unless @event.nil? || @event.student_id == current_user.id || params[:lesson][:student_id].to_i == current_user.id
        render json: {error: 'No autorizado'}, status: :forbidden and return
      end
    end
  end
end