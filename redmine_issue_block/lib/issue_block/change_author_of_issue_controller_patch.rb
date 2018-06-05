module Redmine
  module IssueBlock
    module ChangeAuthorOfIssueControllerPatch
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods

    		receiver.class_eval do
    		  before_filter :check_if_issue_block , only: [:edit, :update]
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
    	end
    	
    	
    end
  end
end