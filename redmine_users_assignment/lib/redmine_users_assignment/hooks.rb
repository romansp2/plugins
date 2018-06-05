module UsersAssignment
  module UsersAssignment

    class Hooks < Redmine::Hook::ViewListener

      render_on( :view_issues_bulk_edit_details_bottom, :partial => 'hooks/user_fields_options')

      def controller_issues_bulk_edit_before_save(context = {})
        return if context[:params][:copy] == "1"

        issue = Issue.find_by_id(context[:issue].id)
        assigned_to_id = context[:params][:issue][:assigned_to_id]
        if assigned_to_id  == 'author'
          context[:issue][:assigned_to_id] = issue.author_id
        elsif (assigned_to_id.is_a? String) && (assigned_to_id.include? 'custom')
          cf_id = context[:params][:issue][:assigned_to_id].split('_')[1].to_i
          c_v = issue.custom_value_for(CustomField.find_by_id(cf_id))
          context[:issue][:assigned_to_id] = c_v.nil? ? nil : c_v.value
        end
        attributes = {'custom_field_values' => {}}
        cfs = context[:params][:issue][:custom_field_values]
        if cfs
          cf_ids = CustomField.where('id' => cfs.keys, 'field_format' => 'user').map { |cf| cf.id.to_s }
          custom_field_values = cfs.select { |key, value| cf_ids.include?(key) }
        else
          custom_field_values = []
        end
        custom_field_values.each do |key, value|
          if value == 'author'
            attributes['custom_field_values'][key] = issue.author_id
          elsif value == 'assigned'
            attributes['custom_field_values'][key] = issue.assigned_to_id
          elsif (value.is_a? String) && (value.include? 'custom')
            cf_id = value.split('_')[1].to_i
            c_v = issue.custom_value_for(CustomField.find_by_id(cf_id))
            attributes['custom_field_values'][key] = c_v.nil? ? nil : c_v.value
          end
        end
        unless attributes.blank?
          context[:issue].safe_attributes = attributes
        end
      end

      def custom_value(issue_id, custom_field_id)
        CustomValue.where('customized_type' => 'Issue',
                          'customized_id'   => issue_id,
                          'custom_field_id' => custom_field_id)[0]
      end

    end

  end
end