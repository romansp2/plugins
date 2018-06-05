require_dependency 'patches/add_block_initiallization_callback_patch'
require_dependency 'hooks/show_html_block_on_page_hook'

Rails.application.config.to_prepare do
  ApplicationController.send(:include, Patches::AddBlockInitiallizationCallbackPatch)
end

Redmine::Plugin.register :html_blocks do
  name 'Html Blocks plugin'
  author 'Rodion  Radchenko'
  description 'Allows to add html blocks at the bottom of a page'
  version '0.0.1'

  menu :application_menu, :blocks, { :controller => 'blocks', :action => 'index' }, :caption => 'Блоки'
end
