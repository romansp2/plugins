module RedmineIssueMailer
  module RedminePatch
    module ApplicationControllerPatch
      def self.included(base) # :nodoc:
      	base.extend(ClassMethods)
       	base.send(:include, InstanceMethods)
       	  # Same as typing in the class
       	base.class_eval do
       	  unloadable # Send unloadable so it will not be unloaded in development
       	end
      end

      module ClassMethods
      end

      module InstanceMethods
      	private
      	  # Find the issue whose id is the :issue_id parameter
		  # Raises a Unauthorized exception if the issue is not visible
		  def find_issue_by_issue_id
		    # Issue.visible.find(...) can not be used to redirect user to the login form
		    # if the issue actually exists but requires authentication
		      @issue = Issue.find(params[:issue_id])
		      raise Unauthorized unless @issue.visible?
		      @project = @issue.project
		    rescue ActiveRecord::RecordNotFound
		      render_404
		  end
      end
    end
  end
end