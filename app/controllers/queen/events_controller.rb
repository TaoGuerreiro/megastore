module Queen
  class EventsController < QueenController
    def index
      if params[:search].present?
        search_events
        respond_to { |format| format.turbo_stream }
      else
        @events = Event.order(created_at: :desc)
        @pagy, @events = pagy(@events)
      end
    end

    def show
      @event = Event.find(params[:id])
    end

    def relaunch
      @event = Event.find(params[:id])
      EventJob.perform_later(@event)

      respond_to do |format|
        format.html { redirect_to queen_events_path, notice: "L'event a été relancé avec succès" }
        format.turbo_stream
      end
    end

    private

    def search_events
      @events = Event.search_by_source_and_data(params[:search])
      @pagy, @events = pagy(@events)
    end
  end
end
