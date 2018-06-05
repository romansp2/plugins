module AddContactsToIssueFormDetailsBottom
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_form_details_bottom(context = {})
      if User.current.allowed_to?(:add_contacts, context[:project])
      	params = context[:controller].params
      	contacts = []
      	if params.include?("contacts_issue") and params["contacts_issue"].include?("contact_ids")
      	  begin
            contacts = Contact.visible.where("contacts.id in (?)",  params["contacts_issue"]["contact_ids"])  
          rescue
            contacts = []
          end      	          
      	end
      	contacts_ids = contacts.map(&:id)
        context[:controller].send(:render_to_string, {partial: '/view_issue/add_contacts_to_issue_form', locals: { :project => context[:project], :issue => context[:issue], :form => context[:form], :contacts => contacts, :contacts_ids => contacts_ids }})
      end
    end
  end
end