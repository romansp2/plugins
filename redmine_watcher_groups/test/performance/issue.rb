require File.expand_path('../../test_helper', __FILE__)
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class IssueModelTest < ActionDispatch::PerformanceTest
  self.profile_options = { :output => './plugins/redmine_watcher_groups/test/performance/tmp/performance'}
  def setup
    # Application requires logged-in user
    user = User.find_by_id(8)
    User.current = user
  end

  def test_issue_visible_alias_from_watcher_group
  	Issue.visible
  end
end
#bundle exec rake test:profile TEST='./plugins/redmine_watcher_groups/test/performance/issue.rb'