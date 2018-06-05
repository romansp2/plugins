require_dependency 'projects_helper'

module HotButtonsPatch
  module AddTabsToProjectSettings
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :project_settings_tabs, :hot_buttons
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def project_settings_tabs_with_hot_buttons
        tabs = project_settings_tabs_without_hot_buttons
        tabs.push({:name => 'hot_buttons', :action => :edit_hot_buttons, :partial => 'hot_buttons/index', :label => :label_hot_buttons})
        tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
      end
    end
  end
end