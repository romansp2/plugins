require 'redmine'

require_dependency 'patches/attachments_patch'
require_dependency 'hooks/view_layouts_base_html_head_hook'

Redmine::Plugin.register :redmine_lightbox2 do
  name 'Redmine Lightbox 2'
  author 'Tobias Fischer'
  description 'This plugin lets you preview image, pdf and swf attachments in a lightbox.'
  version '0.2.7'
  url 'https://github.com/paginagmbh/redmine_lightbox2'
  requires_redmine :version => '3.0'..'3.2'
end



# Patches to the Redmine core.
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'attachments_controller'
    AttachmentsController.send(:include, RedmineLightbox2::AttachmentsPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'attachments_controller'
    AttachmentsController.send(:include, RedmineLightbox2::AttachmentsPatch)
  end
end
