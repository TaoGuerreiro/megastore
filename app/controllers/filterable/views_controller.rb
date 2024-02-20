# frozen_string_literal: true

module Filterable
  class ViewsController < ApplicationController
    def create
      view = Filterable::View.create!(fitlerable_view_params)

      redirect_to view.to_path(filterable_params[:submit_path])
    end

    def destroy
      view = Filterable::View.find(params[:id])

      view.destroy

      redirect_back_or_to(request.referer)
    end

    private

    def fitlerable_view_params
      params.require(:filterable_view)
            .permit(:title, :model, :owner_type, :owner_id, :context_name)
            .merge(query: filterable_params)
    end
  end
end
