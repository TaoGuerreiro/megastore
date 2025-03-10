module Queen
  class EventsController < QueenController
    def index
      @events = Event.order(created_at: :desc)
      @pagy, @events = pagy(@events)
    end

    def show
      @event = Event.find(params[:id])
    end
  end
end
