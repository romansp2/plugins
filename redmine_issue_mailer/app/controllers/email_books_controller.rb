class EmailBooksController < ApplicationController
  unloadable
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  before_filter :find_project_by_project_id
  before_filter :find_email_book, only: [:edit, :update, :destroy]


  def index
    @email_books = @project.email_books
  end

  def show
  end

  def new
    @email_book = @project.email_books.new(new_update_params)
  end

  def create
    @email_book = @project.email_books.create(create_update_params)
    if @email_book.errors.any?
      respond_to do |format|
        format.html{redirect_to new_email_book_path(project_id: @project.id, email_book: params["email_book"]), flash: {error: @email_book.errors.values.flatten.join(', ') } }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to email_books_path(project_id: @project.id), notice: "Success Created"}
      end
      return
    end
  end

  def edit
  end

  def update
    @email_book.update_attributes(create_update_params)
    if @email_book.errors.any?
      respond_to do |format|
        format.html{redirect_to edit_email_book_path(project_id: @project.id, email_book: params["email_book"]), flash: {error: @email_book.errors.values.flatten.join(', ') } }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to email_books_path(project_id: @project.id), notice: "Success Updated"}
      end
      return
    end
  end

  def destroy
    unless @email_book.delete
      respond_to do |format|
        format.html{redirect_to email_books_path(project_id: @project.id), flash: {error: @email_book.errors.values.flatten.join(', ') } }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to email_books_path(project_id: @project.id), notice: "Success Deleted"}
      end
      return
    end
  end

  private
    def find_email_book
      @email_book = @project.email_books.where(id: params[:id]).first
      if @email_book.nil?
        render_404( message: l(:can_not_find_email_in_book, scope: [:redmine_issue_mailer, :error]))
        return
      end
    end

    def new_update_params
      params.permit(:name, :email)
    end
    def create_update_params
      params.require(:email_book).permit(:name, :email)
    end
end
