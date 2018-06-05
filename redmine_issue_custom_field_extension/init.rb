ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue_custom_field_extension_patch/custom_field_patch'
  CustomField.send :include, Redmine::IssueCustomFieldExtensionPatch::CustomFieldPatch

  require_dependency 'issue_custom_field_extension_patch/issue_patch'
  Issue.send :include, Redmine::IssueCustomFieldExtensionPatch::IssuePatch

  require_dependency 'issue_custom_field_extension_patch/custom_values_patch'
  CustomValue.send :include, Redmine::IssueCustomFieldExtensionPatch::CustomValuesPatch

  require_dependency 'issue_custom_field_extension_patch/view_issues_new_top_patch'
  
  if Redmine::VERSION.to_s <= "2.4"
    require_dependency 'issue_custom_field_extension_patch/issue_query_patch'  
    IssueQuery.send(:include, Redmine::IssueCustomFieldExtensionPatch::IssueQueryPatch)

    require_dependency 'issue_custom_field_extension_patch/custom_field_format_patch'
    Redmine::CustomFieldFormat.send :include, Redmine::IssueCustomFieldExtensionPatch::CustomFieldFormatPatch

    require_dependency 'issue_custom_field_extension_patch/custom_fields_helper_patch'
    CustomFieldsHelper.send :include, Redmine::IssueCustomFieldExtensionPatch::CustomFieldsHelperPatch

    require_dependency 'issue_custom_field_extension_patch/controller_issues_new_after_save_patch_v24'

  end
################################# Redmine::VERSION > 2.4
  if Redmine::VERSION.to_s > "2.4"
    require_dependency 'issue_custom_field_extension_patch/field_format_patch'
    Redmine::FieldFormat::UserFormat.send :include, Redmine::IssueCustomFieldExtensionPatch::FieldFormatPatch

    require_dependency 'issue_custom_field_extension_patch/record_list_patch'
    Redmine::FieldFormat::RecordList.send :include, Redmine::IssueCustomFieldExtensionPatch::RecordListPatch

    require_dependency 'issue_custom_field_extension_patch/list_patch'
    Redmine::FieldFormat::List.send :include, Redmine::IssueCustomFieldExtensionPatch::ListPatch

    require_dependency 'issue_custom_field_extension_patch/controller_issues_new_after_save_patch'
  end
end
Redmine::Plugin.register :redmine_issue_custom_field_extension do
  name "Custom Fields' Functional Extension"
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '1.0.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_issue_custom_field_extension.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko/'

  settings :default => {'empty' => true}, :partial => 'issue_custom_field_extension/settings'
end
