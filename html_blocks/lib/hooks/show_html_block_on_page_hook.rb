class ShowHtmlBlockOnPageHook < Redmine::Hook::ViewListener
  render_on :view_layouts_base_body_bottom, :partial => "hooks/html_blocks"
end
