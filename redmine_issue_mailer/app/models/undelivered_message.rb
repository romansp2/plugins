class UndeliveredMessage < ActiveRecord::Base
  unloadable
  belongs_to :issue_sent_on_client_email
end
