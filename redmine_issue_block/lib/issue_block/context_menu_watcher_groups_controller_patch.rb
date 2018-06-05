module Redmine
  module IssueBlock
    module ContextMenuWatcherGroupsControllerPatch

    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods

    		receiver.class_eval do
    		  before_filter :check_if_issue_block, exept: [:autocomplete_for_user]
    		end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
    	  private
    	    def check_if_issue_block
    	      unless @issues.blank?
                @issues.delete_if do |issue| 
                  if issue.block 
                    if issue.block_all_actions? or issue.block_only_watchers?
                      flash[:error] ||= "" 
                      flash[:error] += " Watchers Blocked ##{issue.id} "
                      true
                    end                    
                  end
                end
                if @issues.blank?
                  respond_to do |format|
                    format.js{render js: "alert('Watchers Blocked');"}
                    format.html{redirect_to :back, flash: {error: "Watchers Blocked"}}  
                  end
                  return
                end
              end
    	    end
    		
    	end
    	
    	
    end
  end
end