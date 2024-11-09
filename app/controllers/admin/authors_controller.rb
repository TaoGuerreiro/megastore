module Admin
  class AuthorsController < AdminController
    def index
      @authors = Author.all
    end

    def show
      @author = Author.find(params[:id])
    end

    def new
      @author = Author.new
    end

    def edit
      @author = Author.find(params[:id])
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
        render :new
      end
    end

    def update
      @author = Author.find(params[:id])
      if @author.update(author_params)
        respond_to do |format|
          format.html { redirect_to admin_authors_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :edit
      end
    end

    def destroy
      @author = Author.find(params[:id])
      @author.destroy
      respond_to do |format|
        format.html { redirect_to admin_authors_path, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

    def author_params
      params.require(:author).permit(:website, :nickname, :avatar, :bio)
    end
  end
end
