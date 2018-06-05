module AddProjectSearchFieldHook
  class ViewsIssuesHook < Redmine::Hook::ViewListener     
    def view_layouts_base_body_bottom(context = { })
      context[:controller].send(:render_to_string, {:partial => "add_project_search_field_hooks/project_search_field", :locals => context})
    end
  end
end   