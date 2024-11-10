# frozen_string_literal: true

module Admin
  class CarouselCardsController < AdminController

    def new
      @carousel_card = CarouselCard.new
    end

    def edit
      @carousel_card = CarouselCard.find(params[:id])
    end

    def create
      @carousel_card = CarouselCard.new(carousel_card_params)

      if @carousel_card.save
        respond_to do |format|
          format.html { redirect_to root_path, notice: t(".success") }
          # format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      @carousel_card = CarouselCard.find(params[:id])

      if @carousel_card.update(carousel_card_params)
        respond_to do |format|
          format.html { redirect_to root_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update_position
      @carousel_card = CarouselCard.find(params[:id])
      if @carousel_card.update!(carousel_card_params)
        render json: { status: "ok" }
      else
        render json: { status: "error" }
      end
    end

    def destroy
      @carousel_card = CarouselCard.find(params[:id])
      @carousel_card.destroy

      respond_to do |format|
        format.html { redirect_to root_path }
      end
    end

    private

    def carousel_card_params
      params.require(:carousel_card).permit(:title, :cover, :url, :position_x, :position_y, images: [])
    end
  end
end
