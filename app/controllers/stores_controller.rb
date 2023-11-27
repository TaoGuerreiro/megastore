class StoresController < ApplicationController
  before_action  :set_store, :set_filters

  def show
    if params[:filters]
      @items = @store.items.includes(:category).where(category: {name: selected_filters}, status: :active).order(created_at: :desc)
    else
      @items = @store.items.where(status: :active).order(created_at: :desc)
    end
  end

  private

  def set_filters
    if params[:filters]
      session[:filters] = params.require(:filters).permit(@store.categories.pluck(:name)).to_h { |key, value| [key, value.to_i] }
    else
      session[:filters]  = @store.categories.pluck(:name).map { |name| [name, 1] }.to_h
    end
  end

  def set_store
    @store = Current.store
  end

  def selected_filters
    session[:filters].select { |k, v| v == "1" }.keys
  end
end
