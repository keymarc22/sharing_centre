module Admin
  class GoogleCalendarsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_google_calendar, only: [:sync_now, :fetch_event]
    
    # GET /admin/google_calendars
    def index
      @google_calendars = GoogleCalendar.includes(:user)
                                        .order('users.email ASC, google_calendars.calendar_id ASC')
      
      respond_to do |format|
        format.html
        format.json { render json: @google_calendars }
      end
    end
    
    # POST /admin/google_calendars/:id/sync_now
    def sync_now
      SyncUserCalendarJob.perform_later(@google_calendar.id, force_full_sync: params[:force_full_sync] == 'true')
      
      respond_to do |format|
        format.html do
          flash[:notice] = "Sync job enqueued for calendar #{@google_calendar.calendar_id}"
          redirect_to admin_google_calendars_path
        end
        format.json { render json: { message: 'Sync job enqueued', calendar_id: @google_calendar.id }, status: :accepted }
      end
    end
    
    # POST /admin/google_calendars/sync_all
    def sync_all
      force_full_sync = params[:force_full_sync] == 'true'
      throttle_delay = params[:throttle_delay]&.to_i || 2
      
      SyncAllCalendarsJob.perform_later(force_full_sync: force_full_sync, throttle_delay: throttle_delay)
      
      respond_to do |format|
        format.html do
          flash[:notice] = "Sync job enqueued for all calendars"
          redirect_to admin_google_calendars_path
        end
        format.json { render json: { message: 'Sync all job enqueued' }, status: :accepted }
      end
    end
    
    # POST /admin/google_calendars/:id/fetch_event
    def fetch_event
      event_id = params[:event_id]
      
      unless event_id.present?
        respond_to do |format|
          format.html do
            flash[:error] = "Event ID is required"
            redirect_to admin_google_calendars_path
          end
          format.json { render json: { error: 'Event ID is required' }, status: :unprocessable_entity }
        end
        return
      end
      
      begin
        service = GoogleCalendarService.new(
          user: @google_calendar.user,
          impersonated_email: @google_calendar.user.email
        )
        
        event = service.fetch_event(
          calendar_id: @google_calendar.calendar_id,
          event_id: event_id
        )
        
        if event
          class_session = ClassSession.sync_from_google_event(
            event.to_h.deep_stringify_keys,
            owner_user: @google_calendar.user,
            owner_calendar_id: @google_calendar.calendar_id
          )
          
          respond_to do |format|
            format.html do
              flash[:notice] = "Event fetched and synced successfully"
              redirect_to admin_google_calendars_path
            end
            format.json { render json: { class_session: class_session, event: event }, status: :ok }
          end
        else
          respond_to do |format|
            format.html do
              flash[:error] = "Event not found"
              redirect_to admin_google_calendars_path
            end
            format.json { render json: { error: 'Event not found' }, status: :not_found }
          end
        end
      rescue StandardError => e
        Rails.logger.error("Failed to fetch event: #{e.message}")
        
        respond_to do |format|
          format.html do
            flash[:error] = "Failed to fetch event: #{e.message}"
            redirect_to admin_google_calendars_path
          end
          format.json { render json: { error: e.message }, status: :internal_server_error }
        end
      end
    end
    
    private
    
    def set_google_calendar
      @google_calendar = GoogleCalendar.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html do
          flash[:error] = "Calendar not found"
          redirect_to admin_google_calendars_path
        end
        format.json { render json: { error: 'Calendar not found' }, status: :not_found }
      end
    end
    
    def ensure_admin!
      unless current_user&.role == 'admin'
        respond_to do |format|
          format.html do
            flash[:error] = "Access denied"
            redirect_to root_path
          end
          format.json { render json: { error: 'Access denied' }, status: :forbidden }
        end
      end
    end
  end
end
