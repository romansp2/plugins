module Redmine
  module IssueBlock
    module WatcherGroupsControllerPatch

   	
   	  def self.included(receiver)
   		receiver.extend         ClassMethods
   		receiver.send :include, InstanceMethods

   		receiver.class_eval do
    	  before_filter :check_if_issue_block, except: [:autocomplete_for_group]
    	end
   	  end

   	  module ClassMethods
      end
   	
   	  module InstanceMethods
   	  	private
      	  def check_if_issue_block   
      	  	if !@watched.nil? && @watched.is_a?(Issue) && @watched.block
              if @watched.block_all_actions? or @watched.block_only_watchers?
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