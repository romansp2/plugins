module ChangeAuthorOfIssue
  module IssuesHelperPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :show_detail, :change_author_of_issue_rate  
      end

      base.instance_eval do
        unloadable # Send unloadable so it will not be unloaded in development
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def show_detail_with_change_author_of_issue_rate(detail, no_html=false, options={})
        begin
          case detail.property
            when "issue_author"
               value = detail.value
               old_value = detail.old_value
               if detail.old_value.present?
                  authors = User.where("id IN (?)", [value, old_value])
                  value     = authors.find{|user| "#{user.id}" == value}
                  old_value = authors.find{|user| "#{user.id}" == old_value}
                  return l(:text_journal_changed, :label => content_tag('strong', l(:field_author)), :old => link_to_user(old_value, :class => 'user'), :new => link_to_user(value, :class => 'user')).html_safe
               else
                  author = User.find_by_id value
                  return l(:text_journal_set_to, :label =>  content_tag('strong', l(:field_author)), :value => link_to_user(author, :class => 'user')).html_safe
               end
          else
            show_detail_without_change_author_of_issue_rate(detail, no_html, options)
          end 
        rescue Exception => e
          Rails.logger.error "Error plugin redmine_change_author_of_issue (file: issues_helper_patch.rb lines: [23-38]) #{e.message}"
          show_detail_without_change_author_of_issue_rate(detail, no_html, options)
        end       
      end
    end
  end
end
