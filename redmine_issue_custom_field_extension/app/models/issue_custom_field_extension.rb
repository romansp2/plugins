class IssueCustomFieldExtension < ActiveRecord::Base
  unloadable
  belongs_to :custom_field
end
