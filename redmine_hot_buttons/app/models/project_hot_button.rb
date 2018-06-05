class ProjectHotButton < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :hot_button
end
