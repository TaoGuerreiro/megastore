module Admin
  class AuthorsController < AdminController
    before_action :set_author, only: [:show, :edit, :update, :destroy]

    def index
      @authors = Author.all
      @authors = @authors.search_by_term(params[:search]) if params[:search].present?
      @pagy, @authors = pagy(@authors)

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end

    def show
    end

    def new
      @author = Author.new
    end

    def edit
    end

    def create
      @author = Author.new(author_params)
      @author.store = Current.store

      if @author.save!
        respond_to do |format|
          format.html { redirect_to admin_authors_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @author.update(author_params)
        respond_to do |format|
          format.html { redirect_to admin_authors_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @author.destroy
      respond_to do |format|
        format.html { redirect_to admin_authors_path, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:nickname, :bio, :website, :avatar)
    end
  end
end
