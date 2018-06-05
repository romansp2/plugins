module Redmine
  module IssueBlock
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          before_filter :check_if_issue_block, only: [:edit, :update, :destroy]   
          before_filter :check_if_issue_block_new, only: [:new]     
          before_filter :check_if_issue_block_bulk, only: [:bulk_edit, :bulk_update]    	
        end
      end

      module ClassMethods
      end
      	
      module InstanceMethods
      	private
      	  def check_if_issue_block            
      	  	if !@issue.nil? && @issue.block
              if @issue.block_all_actions?
                redirect_to :back, flash: {error: "Issue blocked"}
                return
              end
            end

            unless @issues.nil?
              if @issues.size == 1
                if @issues[0].block
                  if @issues[0].block_all_actions?
                    redirect_to :back, flash: {error: "Issue blocked"}
                    return
                  end
                end
              else
                @issues.delete_if do |issue| 
                  if issue.block
                    if issue.block_all_actions?
                      flash[:error] ||= "" 
                      flash[:error] += " Blocked ##{issue.id} "
                      true
                    end                    
                  end
                end
                if @issues.blank?
                  redirect_to :back
                  return
                end
              end              
            end
      	  end

          def check_if_issue_block_new            
            if !@issue.nil? && !params[:issue].nil? && !params[:issue][:parent_issue_id].nil?
              issue = Issue.find_by_id(params[:issue][:parent_issue_id])
              if !issue.nil? && issue.block_all_actions?
                redirect_to :back, flash: {error: "Issue Blocked"}
                return
              end
            end
          end

          def check_if_issue_block_bulk
            unless @issues.blank?
              @issues.delete_if do |issue| 
                if issue.block
                  if issue.block_all_actions?
                    flash[:error] ||= "" 
                    flash[:error] += " Blocked ##{issue.id} "
                    true
                  end                    
                end
              end
              if @issues.blank?
                redirect_to :back
                return
              end
            end
          end
      end     
    end
  end
end
