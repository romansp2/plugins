class CcwiContactsIssuesController < ApplicationController
  unloadable
  before_filter :require_login
  before_filter :find_project, only: [:add_contacts, :new, :autocomplete_for_contact, :destroy]
  before_filter :allowed_add_contacts
  def new
  	contact_ids = []
    if params[:contacts_issue].is_a?(Hash)
      contact_ids << (params[:contacts_issue][:contact_ids] || params[:contacts_issue][:contact_id])
    else
      contact_ids << params[:contact_id]
    end
  	@contact_ids = contact_ids.flatten.compact.uniq
  	@contacts = Contact.visible.where("contacts.id in (?)", @contact_ids)
  end

  def add_contacts
  	contact_ids = []
    if params[:contacts_issue].is_a?(Hash)
      contact_ids << (params[:contacts_issue][:contact_ids] || params[:contacts_issue][:contact_id])
    else
      contact_ids << params[:contact_id]
    end
    @contact_ids = contact_ids.flatten.compact.uniq
    @contacts = Contact.visible.where("contacts.id in (?)", @contact_ids)
  end

  def destroy
    contact_ids = []
    if params[:contacts_issue].is_a?(Hash)
      contact_ids << (params[:contacts_issue][:contact_ids] || params[:contacts_issue][:contact_id])
    else
      contact_ids << params[:contact_id]
    end
    @contact_id = params[:id]
    @contact_ids = contact_ids.flatten.compact.uniq.delete_if{|id| id=="#{@contact_id}"}
    @contacts = Contact.visible.where("contacts.id in (?)", @contact_ids)
  end

  def autocomplete_for_contact
  	contact_ids = []
    if params[:contacts_issue].is_a?(Hash)
      contact_ids << (params[:contacts_issue][:contact_ids] || params[:contacts_issue][:contact_id])
    else
      contact_ids << params[:contact_id]
    end
    
  	q = params[:q].to_s
    scope = Contact.where(nil)
    q.split(' ').collect{ |search_string| scope = scope.live_search(search_string) } unless q.blank?
    @contact_ids = contact_ids.flatten.compact.uniq
    unless @contact_ids.empty?
      scope = scope.where("contacts.id not in (?)", @contact_ids)
    end
    @contacts = scope.visible.includes(:avatar).order(Contact.fields_for_order_statement).by_project(params[:cross_project_contacts] == "1" ? nil : @project).limit(100)
    
    render :layout => false
  end

  private

    def allowed_add_contacts
      unless User.current.allowed_to?(:add_contacts, @project)
        render_403
      end
    end

    def find_project
        project_id = params[:project_id]
        @project = Project.find(project_id)
      rescue ActiveRecord::RecordNotFound
        render_404
    end
end
