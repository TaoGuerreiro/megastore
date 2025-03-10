# frozen_string_literal: true

module Ttt
  class AuthorsController < ApplicationController
    before_action :ensure_ttt_store
    layout "application"

    def index
      @authors = Author.all
      @authors = @authors.search_by_term(params[:search]) if params[:search].present?

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end

    def show
      @author = Author.find(params[:id])

      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.update("modale", partial: "author") }
      end
    end

    private

    def ensure_ttt_store
      redirect_to root_path unless Current.store&.slug == "ttt"
    end
  end
end
