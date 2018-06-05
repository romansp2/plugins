require_dependency 'queries_helper'

module RedmineHelpdesk
  module Patches
    module GravatarHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :gravatar_api_url, :helpdesk
        end
      end

      module InstanceMethods
        def gravatar_api_url_with_helpdesk(hash)
          [Setting[:protocol], ':', gravatar_api_url_without_helpdesk(hash)].join
        end
      end
    end
  end
end

unless GravatarHelper::PublicMethods.included_modules.include?(RedmineHelpdesk::Patches::GravatarHelperPatch)
  GravatarHelper::PublicMethods.send(:include, RedmineHelpdesk::Patches::GravatarHelperPatch)
end
