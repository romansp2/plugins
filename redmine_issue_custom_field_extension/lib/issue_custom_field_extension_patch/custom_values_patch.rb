module Redmine
  module IssueCustomFieldExtensionPatch
  	module CustomValuesPatch
  		
  		
  		def self.included(receiver)
  			receiver.extend         ClassMethods
  			receiver.send :include, InstanceMethods

  			receiver.class_eval do 
              unloadable # Send unloadable so it will not be unloaded in development
              after_save :add_to_issue_as_watcher
  			end
  		end

  		module ClassMethods
  			
  		end
  		
  		module InstanceMethods
  		  private
  		    def add_to_issue_as_watcher
            begin
              unless !self.changed? or self.value.nil? or self.value.blank?
                custom_field_ = self.custom_field
                if custom_field.field_format == 'user' and custom_field.type == 'IssueCustomField'
                  custom_field_extension = custom_field_.issue_custom_field_extension
                  if !custom_field_extension.blank? and custom_field_extension.extends and custom_field_extension.add_as_watcher
                    ###
                    group = nil
                    user = User.find_by_id self.value
                    (group = Group.find_by_id(self.value)) if user.blank?
                    (return) if group.blank? and user.blank?
                    notification_for_users = []
                    ##issue
                    issue           = Issue.find_by_id self.customized_id
                    author_of_issue = issue.author
                    assigned_to     = issue.assigned_to
                    ##
                    if !user.nil?
                      watched = Watcher.create(:watchable_type => 'Issue', :watchable_id => self.customized_id, :user_id => self.value)
                      if watched.valid?
                        notification_for_users << user if user.active? and user != author_of_issue and user != assigned_to
                      end
                    elsif !group.nil? and Redmine::Plugin.installed?(:redmine_watcher_groups)
                      if Watcher.find(:all, 
                                      :conditions => "watchable_type='Issue' and watchable_id = #{self.customized_id} and user_id = '#{self.value}'",
                                      :limit => 1).blank?
                                      # insert directly into table to avoit user type checking
                        Watcher.connection.execute("INSERT INTO `#{Watcher.table_name}` (`user_id`, `watchable_id`, `watchable_type`) VALUES (#{self.value}, #{self.customized_id}, 'Issue')")
                        
                        if group != assigned_to
                          notification_for_users += group.users.uniq.select {|u| (u.active? and u != author_of_issue and u != assigned_to) }
                        end
                      end
                    end
                    notified = notification_for_users.flatten.uniq.select {|u| u.active? && u.notify_about?(issue)}
                    users = notified

                    if Setting.notified_events.include?('issue_updated') and !users.empty? and Redmine::VERSION.to_s <= "2.4"
                      begin
                        if !users.empty? and !issue.blank? and issue.updated_on == issue.created_on and (Time.now.utc - issue.created_on.utc).seconds < 4
                          users_mails = users.collect(&:mail)
                          mail = Mailer.issue_add(issue)
                          mail.to = users_mails
                          mail.bcc = users_mails
                          mail.cc = []
                          mail.deliver
                        end
                      rescue Exception => e
                        Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:custom_values_patch.rb str:[] #{e}" 
                      end
                    elsif !users.empty? and Redmine::VERSION.to_s > "2.4"
                      begin
                        if issue.notify? and Setting.notified_events.include?('issue_updated') and !users.empty? and !issue.blank? and issue.updated_on == issue.created_on and (Time.now.utc - issue.created_on.utc).seconds < 4
                          if Setting.plugin_redmine_issue_custom_field_extension["use_sidekiq"] == "true"
                            IssueCustomFieldExtensionMailerIssueAddWatchersWorker.perform_async(issue.to_json, users.map(&:id).to_json)
                          else
                            Mailer.issue_add(issue, users, []).deliver
                          end
                        end
                      rescue Exception => e
                        Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:custom_values_patch.rb str:[] #{e}" 
                      end
                    end
                  end#if !custom_field_extension.blank? and custom_field_extension.extends and custom_field_extension.add_as_watcher
                end#if custom_field.field_format == 'user' and custom_field.type == 'IssueCustomField'
              end
            rescue Exception => e
              Rails.logger.error "Plugin redmine_issue_custom_field_extension File:custom_values_patch.rb Strings:[] Error: #{e}"
            end
  		    end
  		end
  	end

  end
end