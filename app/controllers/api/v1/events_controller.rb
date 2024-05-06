module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_profile, only: %i[view]

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
    end
  end
end
