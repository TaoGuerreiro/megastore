# frozen_string_literal: true

class StoresController < ApplicationController
  before_action :set_store, :set_filters

  def show
    @max_price = max_price
    @min_price = min_price
    @default_sort = default_sort
    @query = params.dig(:filters, :query)
    @items = fetch_items
    @collections = @store.active_collections_with_items

    return unless params[:filters]

    respond_to do |format|
      format.turbo_stream
    end
  end

  def library
    redirect_to store_path(Current.store) if Current.store.slug = !"ttt"
    Current.store.update(slug: "ttt")

    @max_price = max_price
    @min_price = min_price
    @default_sort = default_sort
    @query = params.dig(:filters, :query)
    @items = fetch_items
    @collections = @store.active_collections_with_items

    return unless params[:filters]

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def max_price
    params.dig(:filters, :max_price) || @store.items&.maximum(:price_cents)&.fdiv(100)
  end

  def min_price
    params.dig(:filters, :min_price) || 0.00
  end

  def default_sort
    params.dig(:filters, :sort) || "Nouveautés"
  end

  def fetch_items
    return @store.items.where(status: :active, collection_id: nil).order(created_at: :desc) unless params[:filters]

    items = @store.items.includes(:category).where(category: { name: selected_filters },
                                                   status: :active).where(price_range_inputs).order(sorting_input)
    items = items.search_by_name_and_description(@query) if @query.present? && @query != ""
    items
  end

  def sorting_input
    case params.dig(:filters, :sort)
    when "Prix croissant"
      "items.price_cents ASC"
    when "Prix décroissant"
      "items.price_cents DESC"
    when "A-Z"
      "items.name ASC"
    else
      "items.created_at DESC"
    end
  end

  def price_range_inputs
    min_price_cents = params.dig(:filters, :min_price).gsub(",", ".").to_f * 100
    max_price_cents = params.dig(:filters, :max_price).gsub(",", ".").to_f * 100
    "items.price_cents >= #{min_price_cents} AND items.price_cents <= #{max_price_cents}"
  end

  def set_filters
    session[:filters] = if params[:filters]
                          params.require(:filters).permit(@store.categories.pluck(:name)).transform_values(&:to_i)
                        else
                          @store.categories.pluck(:name).index_with { |_name| 1 }
                        end
  end

  def set_store
    @store = Current.store
  end

  def selected_filters
    session[:filters].select { |_k, v| v == 1 }.keys
  end
end
