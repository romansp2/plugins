module ViewLayoutsBaseHtmlHeadPatch
  class ViewsLayoutsHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context={})
      return stylesheet_link_tag(:change_author_of_issue, :plugin => 'redmine_change_author_of_issue') 
    end
  end
end