module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_profile, only: %i[view create]

      def index
        today_events = Event.today_events(current_user)
        render json: { events: today_events }, 
               status: :ok
      end

      def view
        start_date = params[:event][:from_date]
        end_date = params[:event][:to_date]

        if current_user.can_view_events_of?(@profile)
          events = Event.events_within_date_range(@profile, start_date, end_date)
          render json: { events: events },
                 status: :ok
        else
          render json: { error: 'You are not authorized to perform this action' },
                 status: :forbidden
        end
      end

      def create
        if current_user.can_create_event_for?(@profile)
          start_date = params[:event][:start_date]
          end_date = params[:event][:end_date]
          location = params[:event][:location]

          overlapping_events = Event.overlapping_events(@profile, start_date, end_date)

          if overlapping_events.any?
            render json: { error: 'There is already an event scheduled within this time range' },
                   status: :unprocessable_entity
          else
            event = Event.new(event_params)
            event.profile = @profile

            if event.save
              weather = get_weather(location)
              send_email(event, weather)
              render json: { status: 'Event created successfully', event: event },
                     status: :created
            else
              render json: { error: 'Failed to create event', errors: event.errors },
                     status: :unprocessable_entity
            end
          end
        else
          render json: { error: 'You do not have permission to create events for this profile' },
                 status: :unauthorized
        end
      end

      private

      def event_params
        params.require(:event).permit(:title, :start_date, :end_date, :profile_id, :location)
      end

      def set_profile
        @profile = Profile.find(params[:event][:profile_id])
      end

      def send_email(event, weather)
        EmailService.new(event, weather).call
      end

      def get_weather(location)
        location.present? ? fetch_weather(location) : nil
      end

      def fetch_weather(location)
        client = OpenWeather::Client.new(api_key: ENV['OPEN_WEATHER_API_KEY'])
        client.current_weather(city: location)
      end
    end
  end
end
