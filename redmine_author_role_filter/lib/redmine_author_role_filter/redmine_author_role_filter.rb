module RedmineAuthorRoleFilter
  module QueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :available_filters, :author_role
      end
    end

    module InstanceMethods

      # Wrapper around the +available_filters+ to add a new Deliverable filter
      def available_filters_with_author_role

        @available_filters = available_filters_without_author_role

        role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
        author_role_filter = {
            "author_role" => {
                :name => l('author_role_filter.field_author_role'),
                :type => :list_optional,
                :values => role_values
            }
        }

        @available_filters.merge!(author_role_filter)
      end

      def sql_for_author_role_field(field, operator, value)
        case operator

          when "*", "!*" # Member / Not member

            sw = operator == "!*" ? 'NOT' : ''

            nl = operator == "!*" ? "#{Issue.table_name}.author_id IS NULL OR" : ''

            "(#{nl} #{Issue.table_name}.author_id #{sw} IN (SELECT DISTINCT #{Member.table_name}.user_id FROM #{Member.table_name}" +

                " WHERE #{Member.table_name}.project_id = #{Issue.table_name}.project_id))"

          when "=", "!"

            role_cond = value.any? ?

                "#{MemberRole.table_name}.role_id IN (" + value.collect{|val| "'#{self.class.connection.quote_string(val)}'"}.join(",") + ")" :

                "1=0"


            sw = operator == "!" ? 'NOT' : ''

            nl = operator == "!" ? "#{Issue.table_name}.author_id IS NULL OR" : ''

            "(#{nl} #{Issue.table_name}.author_id #{sw} IN (SELECT DISTINCT #{Member.table_name}.user_id FROM #{Member.table_name}, #{MemberRole.table_name}" +

                " WHERE #{Member.table_name}.project_id = #{Issue.table_name}.project_id AND #{Member.table_name}.id = #{MemberRole.table_name}.member_id AND #{role_cond}))"

        end
      end

    end
  end
end

Query.send(:include, RedmineAuthorRoleFilter::QueryPatch)