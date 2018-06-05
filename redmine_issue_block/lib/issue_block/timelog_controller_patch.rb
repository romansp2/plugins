module Redmine
  module IssueBlock
    module TimelogControllerPatch
  	  def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods

		receiver.class_eval do
		  before_filter :check_if_issue_block, only: [:new, :create]
		  before_filter :check_if_issue_block_edit, only: [:edit]
		  before_filter :check_if_issue_block_destroy, only: [:destroy]
        end
	  end

	  module ClassMethods
			
	  end
		
	  module InstanceMethods
	    private
	      def check_if_issue_block
	        if !@issue.nil? && @issue.block
              if @issue.block_all_actions?
		        respond_to do |format|
		      	  format.js{render js: "alert('Issue blocked');"}
		      	  format.html{redirect_to :back, flash: {error: "Issue blocked"}}	
		      	end
		        return
		      end
	        end
	      end

	      def check_if_issue_block_edit
	      	issue =  @time_entry.issue
	      	if !issue.nil? and issue.block
              if issue.block_all_actions?
	      	    respond_to do |format|
	      	      format.js{render js: "alert('Issue blocked');"}
	      	  	  format.html{redirect_to :back, flash: {error: "Issue blocked"}}	
	      	    end
	            return
	          end
	        end
	      end

	      def check_if_issue_block_destroy
            @time_entries
            @time_entries.delete_if do |time_entry|
              issue = time_entry.issue
              if !issue.nil? && issue.block
                if issue.block_all_actions?
                  flash[:notice] ||= ""
                  flash[:notice] += " Blocked ##{issue.id}"
                  true
                end
              else
                false
              end
            end 
            if @time_entries.empty?
              redirect_to :back, flash: {error: "Issue(s) blocked"}
              return
            end
	      end
		end
	  end
	end
end

