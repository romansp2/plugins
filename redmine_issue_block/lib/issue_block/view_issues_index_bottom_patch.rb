module IssueBlockPatch
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_index_bottom(context = {})
      context[:controller].send(:render_to_string, {partial: '/issue_block/view_issues_index_bottom', locals: context})
    end    
  end
end




#call_hook(:view_issues_index_bottom, { :issues => @issues, :project => @project, :query => @query })