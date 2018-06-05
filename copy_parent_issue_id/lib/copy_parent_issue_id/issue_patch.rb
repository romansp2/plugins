module RedmineCopyParentIssueId
  module IssuePatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :copy_from, :parent_id
      end
    end
  
    module InstanceMethods

      def copy_from_with_parent_id(arg, options={})
        copy_from_without_parent_id(arg, options)

        self.parent_issue_id = @copied_from.parent_issue_id

        self
      end
    end
  end
end

# Add module to Issue
Issue.send(:include, RedmineCopyParentIssueId::IssuePatch)
