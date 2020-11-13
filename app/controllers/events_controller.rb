class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = GroupEvent.not_deleted
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # POST /events
  # POST /events.json
  def create
    @event = GroupEvent.new(event_params)
    if @event.valid?
      @event.calculate_date_fields
    end
    if @event.save
      render :show, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    if @event.update(event_params)
      render :show, status: :ok
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = GroupEvent.not_deleted.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:group_event).permit(:start_date, :end_date, :duration, :name, :description, :location)
    end
end
