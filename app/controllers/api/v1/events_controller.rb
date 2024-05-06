module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user!

      def index
        today_events = Event.today_events(current_user)

        render json: { events: today_events },
               status: :ok
      end
    end
  end
end
