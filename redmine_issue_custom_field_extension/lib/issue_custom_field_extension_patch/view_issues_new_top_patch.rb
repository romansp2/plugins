class Hooks < Redmine::Hook::ViewListener
  def view_issues_form_details_bottom(context = {})
  	if context[:controller].action_name == "new" or context[:issue].new_record?
  	  context[:controller].send(:render_to_string, {partial: 'issue_custom_field_extension/default_value_for_new_issue', locals: context})
    end
  end
end

#call_hook(:view_issues_new_top, {:issue => @issue})
#call_hook(:view_issues_form_details_bottom, { :issue => @issue, :form => f })