require 'rails_helper'

RSpec.describe "CalendarsController Google Calendar integration", type: :request do
  let(:teacher) { create(:teacher, :with_google_oauth) }
  let(:student) { create(:student) }

  let(:session_params) do
    {
      class_session: {
        title: "Clase de prueba",
        description: "Descripción",
        start_at: 1.day.from_now.iso8601,
        end_at: (1.day.from_now + 1.hour).iso8601,
        teacher_id: teacher.id,
        student_id: student.id,
        time_zone: "UTC"
      }
    }
  end

  let(:mock_google_event) do
    double("Google::Apis::CalendarV3::Event",
      id: "google_event_abc123",
      hangout_link: "https://meet.google.com/abc-defg-hij",
      conference_data: nil
    )
  end

  let(:mock_calendar_service) { instance_double(GoogleCalendarService) }

  before do
    sign_in teacher, scope: :user
    allow(GoogleCalendarService).to receive(:new).with(teacher).and_return(mock_calendar_service)
  end

  describe "POST /calendars (create)" do
    context "cuando el teacher tiene Google conectado" do
      before do
        allow(mock_calendar_service).to receive(:create_event).and_return(mock_google_event)
      end

      it "crea la ClassSession en la base de datos" do
        expect {
          post calendars_path, params: session_params
        }.to change(ClassSession, :count).by(1)
      end

      it "llama a GoogleCalendarService con los parámetros correctos del evento" do
        expect(mock_calendar_service).to receive(:create_event).with(
          hash_including(
            summary: "Clase de prueba",
            description: "Descripción"
          )
        ).and_return(mock_google_event)

        post calendars_path, params: session_params
      end

      it "guarda el google_event_id en la ClassSession" do
        post calendars_path, params: session_params

        expect(ClassSession.last.google_event_id).to eq("google_event_abc123")
      end

      it "guarda el meet_link en la ClassSession" do
        post calendars_path, params: session_params

        expect(ClassSession.last.meet_link).to eq("https://meet.google.com/abc-defg-hij")
      end

      it "guarda el google_calendar_owner_id como el teacher actual" do
        post calendars_path, params: session_params

        expect(ClassSession.last.google_calendar_owner_id).to eq(teacher.id)
      end

      it "responde con 201 created" do
        post calendars_path, params: session_params

        expect(response).to have_http_status(:created)
      end

      it "incluye los attendees del teacher y student en el evento de Google" do
        expect(mock_calendar_service).to receive(:create_event).with(
          hash_including(
            attendees: array_including(
              { email: teacher.email },
              { email: student.email }
            )
          )
        ).and_return(mock_google_event)

        post calendars_path, params: session_params
      end

      context "cuando Google Calendar falla" do
        before do
          allow(mock_calendar_service).to receive(:create_event)
            .and_raise(Google::Apis::Error.new("API Error"))
        end

        it "igual crea la ClassSession (Google falla silenciosamente)" do
          expect {
            post calendars_path, params: session_params
          }.to change(ClassSession, :count).by(1)
        end

        it "responde con 201 created aunque Google falle" do
          post calendars_path, params: session_params

          expect(response).to have_http_status(:created)
        end

        it "deja el google_event_id en nil" do
          post calendars_path, params: session_params

          expect(ClassSession.last.google_event_id).to be_nil
        end
      end
    end

    context "cuando el teacher NO tiene Google conectado" do
      let(:teacher_no_google) { create(:teacher) }

      before { sign_in teacher_no_google, scope: :user }

      it "crea la ClassSession sin llamar a GoogleCalendarService" do
        expect(GoogleCalendarService).not_to receive(:new)

        post calendars_path, params: {
          class_session: session_params[:class_session].merge(teacher_id: teacher_no_google.id)
        }
      end

      it "crea la ClassSession sin google_event_id" do
        post calendars_path, params: {
          class_session: session_params[:class_session].merge(teacher_id: teacher_no_google.id)
        }

        expect(ClassSession.last.google_event_id).to be_nil
      end
    end
  end

  describe "PATCH /calendars/:id (update)" do
    let!(:class_session) do
      create(:class_session,
        teacher: teacher,
        student: student,
        google_event_id: "existing_google_event_id",
        google_calendar_owner_id: teacher.id
      )
    end

    let(:updated_mock_event) do
      double("Google::Apis::CalendarV3::Event",
        hangout_link: "https://meet.google.com/updated-link",
        conference_data: nil
      )
    end

    context "cuando la sesión tiene google_event_id y el teacher tiene Google conectado" do
      before do
        allow(mock_calendar_service).to receive(:update_event).and_return(updated_mock_event)
      end

      it "llama a update_event con el google_event_id correcto" do
        expect(mock_calendar_service).to receive(:update_event)
          .with("existing_google_event_id", hash_including(summary: "Título actualizado"))
          .and_return(updated_mock_event)

        patch calendar_path(class_session), params: {
          class_session: { title: "Título actualizado" }
        }
      end

      it "actualiza el meet_link si Google devuelve uno nuevo" do
        patch calendar_path(class_session), params: {
          class_session: { title: "Título actualizado" }
        }

        expect(class_session.reload.meet_link).to eq("https://meet.google.com/updated-link")
      end

      it "responde con 200 ok" do
        patch calendar_path(class_session), params: {
          class_session: { title: "Título actualizado" }
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context "cuando la sesión NO tiene google_event_id" do
      let!(:session_without_google) do
        create(:class_session, teacher: teacher, student: student, google_event_id: nil)
      end

      it "no llama a update_event" do
        expect(mock_calendar_service).not_to receive(:update_event)

        patch calendar_path(session_without_google), params: {
          class_session: { title: "Sin Google" }
        }
      end
    end
  end

  describe "DELETE /calendars/:id (destroy)" do
    let!(:class_session) do
      create(:class_session,
        teacher: teacher,
        student: student,
        google_event_id: "event_to_delete",
        google_calendar_owner_id: teacher.id
      )
    end

    context "cuando la sesión tiene google_event_id y el teacher tiene Google conectado" do
      before do
        allow(mock_calendar_service).to receive(:delete_event)
      end

      it "llama a delete_event con el google_event_id correcto" do
        expect(mock_calendar_service).to receive(:delete_event).with("event_to_delete")

        delete calendar_path(class_session)
      end

      it "elimina la ClassSession de la base de datos" do
        expect {
          delete calendar_path(class_session)
        }.to change(ClassSession, :count).by(-1)
      end

      it "responde con 204 no content" do
        delete calendar_path(class_session)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "cuando la sesión NO tiene google_event_id" do
      let!(:session_without_google) do
        create(:class_session, teacher: teacher, student: student, google_event_id: nil)
      end

      it "elimina la ClassSession sin llamar a delete_event" do
        expect(mock_calendar_service).not_to receive(:delete_event)

        delete calendar_path(session_without_google)
      end
    end
  end

  describe "POST /calendars/sync" do
    let(:google_event_1) do
      double("Google::Apis::CalendarV3::Event",
        id: "goog_event_1",
        summary: "Clase importada",
        description: "Desc",
        start: double(date_time: 1.day.from_now, time_zone: "UTC", date: nil),
        end: double(date_time: 1.day.from_now + 1.hour, time_zone: "UTC", date: nil),
        hangout_link: "https://meet.google.com/sync-link"
      )
    end

    before do
      allow(mock_calendar_service).to receive(:list_events).and_return([google_event_1])
    end

    it "llama a list_events en Google Calendar" do
      expect(mock_calendar_service).to receive(:list_events).and_return([])

      post sync_calendars_path
    end

    it "responde con synced: true" do
      post sync_calendars_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("synced" => true)
    end

    context "cuando Google Calendar falla" do
      before do
        allow(mock_calendar_service).to receive(:list_events)
          .and_raise(StandardError.new("Network error"))
      end

      it "responde con error y status 422" do
        post sync_calendars_path

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Network error")
      end
    end
  end
end
