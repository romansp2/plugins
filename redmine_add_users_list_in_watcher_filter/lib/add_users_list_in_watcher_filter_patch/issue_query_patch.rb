module Redmine 
  module AddUsersListInWatcherFilterPatch
    module IssueQueryPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanseMethods)
        base.class_eval do 
          unloadable
          alias_method :copy_origin_initialize_available_filters_for_users_list_in_watcher_filter_patch, :initialize_available_filters
          def initialize_available_filters
            copy_origin_initialize_available_filters_for_users_list_in_watcher_filter_patch
            if User.current.logged? and !@available_filters.blank?
              @available_filters["watcher_id"] = @available_filters["assigned_to_id"].dup
            end
          end
        end

      end


      module ClassMethods
      end

      module InstanseMethods
      end
    end
  end
end