class NoMailConfiguration < RuntimeError;
end

class EmailNotificationForAuthor < Mailer
  include Redmine::I18n

  #prepend_view_path "#{Redmine::Plugin.find("due_date_reminder").directory}/app/views"

  def self.of_issue_where_status_in 
    unless ActionMailer::Base.perform_deliveries
      raise NoMailConfiguration.new(l(:text_email_delivery_not_configured))
    end

    issue_status_for_check = Setting.plugin_email_notification_for_author_of_issue_where_status_in["check"]
    issue_status_for_close = Setting.plugin_email_notification_for_author_of_issue_where_status_in["close"]#nil, ""

    issue_status_for_check = IssueStatus.where("id = ?", issue_status_for_check).pluck(:id).first
    issue_status_for_close = IssueStatus.where("id = ?", issue_status_for_close).pluck(:id).first 

    close_f = Setting.plugin_email_notification_for_author_of_issue_where_status_in["close_f"]
    check_f = Setting.plugin_email_notification_for_author_of_issue_where_status_in["check_f"]

    Rails.logger.info "Plugin 'email_notification_for_author_of_issue_where_status_in'  Settings:  Status in ready for ckeck issue: #{issue_status_for_check} Status in ready for close issue: #{issue_status_for_close}"
    Rails.logger.info "Plugin 'email_notification_for_author_of_issue_where_status_in'  Settings:  Custom Fields for notification about issues ready for ckeck: #{check_f} Custom Fields for notification about issues ready for close: #{close_f}"

    #issue_status_for_close
    close_f_author = nil
    close_f_users_from_field_ids = nil
    if !issue_status_for_close.blank?
      unless close_f.nil?
        close_f_author               = close_f["author"]
        close_f_users_from_field_ids = close_f["users_from_field_ids"] || []
        unless close_f_users_from_field_ids.empty?
          close_f_users_from_field_ids = CustomField.where("type='IssueCustomField' and field_format='user' AND id IN (?)", close_f_users_from_field_ids).pluck(:id)
          Rails.logger.info "Plugin 'email_notification_for_author_of_issue_where_status_in'  Settings:  Custom Fields for notification about issues ready for close DB ids: #{close_f_users_from_field_ids}"
        end
      end
    end
  
    #issue_status_for_check
    check_f_author = nil
    check_f_users_from_field_ids = nil
    if !issue_status_for_check.blank?
      unless check_f.nil?
        check_f_author               = check_f["author"]
        check_f_users_from_field_ids = check_f["users_from_field_ids"] || []
        unless check_f_users_from_field_ids
          check_f_users_from_field_ids = CustomField.where("type='IssueCustomField' and field_format='user' AND id IN (?)", check_f_users_from_field_ids).pluck(:id)
          Rails.logger.info "Plugin 'email_notification_for_author_of_issue_where_status_in'  Settings:  Custom Fields for notification about issues ready for ckeck DB ids: #{check_f_users_from_field_ids}"
        end
      end
    end

    if  (!close_f.nil? or !check_f.nil?) and ( !issue_status_for_check.nil? or !issue_status_for_close.nil? )      
      #close_in_projects = Project.where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE).includes([ :issues => [ {:custom_values => [:custom_field]}, :status, :author, :tracker ] ]).scoped({})
      User.where("status = ?", User::STATUS_ACTIVE).find_each do |user|
        
        close_in_projects = []
        check_in_projects = []
        begin
          #request to DB for issue_status_for_close

          if !issue_status_for_close.blank? and ( !close_f_author.nil? or !close_f_users_from_field_ids.empty?)

            close_in_projects_scoped = Project.where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE).eager_load([ :issues => [ {:custom_values => [:custom_field]}, :status, :author, :tracker ] ]).where("issues.status_id = ?", issue_status_for_close).where(nil)#scoped({})
            if !close_f_author.nil? and !close_f_users_from_field_ids.empty?
              close_in_projects_scoped = close_in_projects_scoped.where("( (custom_fields.id IN (?) 
                                                                            and custom_fields.field_format = 'user' 
                                                                            and custom_values.value=?
                                                                           ) 
                                                                           or issues.author_id=?)", close_f_users_from_field_ids, "#{user.id}", user.id)
            end
            if close_f_author.nil? and !close_f_users_from_field_ids.empty?
              close_in_projects_scoped = close_in_projects_scoped.where("( custom_fields.id IN (?) 
                                                                           and custom_fields.field_format = 'user' 
                                                                           and custom_values.value=?
                                                                          ) ", close_f_users_from_field_ids, "#{user.id}")
            end  
            if !close_f_author.nil? and close_f_users_from_field_ids.empty?
              close_in_projects_scoped = close_in_projects_scoped.where("(issues.author_id=?)", user.id)
            end
            close_in_projects = close_in_projects_scoped.all
          end
        rescue Exception => e
          Rails.logger.error "Plugin 'email_notification_for_author_of_issue_where_status_in' request to DB for issue_status_for_close  Error: #{e} "
        end
        #
        begin
          #request to DB for issue_status_for_check
          if !issue_status_for_check.blank? and ( !check_f_author.nil? or !check_f_users_from_field_ids.empty?)
            check_in_projects_scoped = Project.where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE).eager_load([ :issues => [ {:custom_values => [:custom_field]}, :status, :author, :tracker ] ]).where("issues.status_id = ?", issue_status_for_check).where(nil)#scoped({})
            if !check_f_author.nil? and !check_f_users_from_field_ids.empty?
              check_in_projects_scoped = check_in_projects_scoped.where("( (custom_fields.id IN (?) 
                                                                            and custom_fields.field_format = 'user' 
                                                                            and custom_values.value=?
                                                                           ) 
                                                                           or issues.author_id=?)", check_f_users_from_field_ids, "#{user.id}", user.id)
            end
            if check_f_author.nil? and !check_f_users_from_field_ids.empty?
              check_in_projects_scoped = check_in_projects_scoped.where("( custom_fields.id IN (?) 
                                                                           and custom_fields.field_format = 'user' 
                                                                           and custom_values.value=?
                                                                          ) ", check_f_users_from_field_ids, "#{user.id}")
            end     
            if !check_f_author.nil? and check_f_users_from_field_ids.empty? 
              check_in_projects_scoped = check_in_projects_scoped.where("(issues.author_id=?)", user.id)
            end
            check_in_projects = check_in_projects_scoped.all
          end
        rescue Exception => e
          Rails.logger.error "Plugin 'email_notification_for_author_of_issue_where_status_in' request to DB for issue_status_for_check  Error: #{e} "
        end
        #email deliver
        begin
          if !close_in_projects.empty? or !check_in_projects.empty?
            mail = user.mail
            unless user.mail.nil?
              close_and_check(user, close_in_projects, check_in_projects).deliver
            end
          end
        rescue Exception => e
          Rails.logger.error "Plugin 'email_notification_for_author_of_issue_where_status_in' email deliver  Error: #{e} "
        end
      end
    end       
  end

  def close_and_check(user, close_in_projects, check_in_projects)
    set_language_if_valid user.language
  
    @close_in_projects = close_in_projects
    @check_in_projects = check_in_projects
    
    @user = user
    mail :to => user.mail, :subject => l(:email_for_author_subject)
  end
end
