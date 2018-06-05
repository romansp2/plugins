module CcwiControllerIssuesNewAfterSave
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_new_after_save(context = {})
      if User.current.allowed_to?(:add_contacts, context[:project])
      	contact_ids = []
      	contacts_issue = context[:params][:contacts_issue]
        if contacts_issue.is_a?(Hash)
          contact_ids << contacts_issue[:contact_ids] 
        end
        issue = context[:issue]
        contact_ids.flatten.compact.uniq.each do |contact_id|
          ContactsIssue.create(:issue_id => issue.id, :contact_id => contact_id)
        end
      end
    end
  end
end