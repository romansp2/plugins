require File.expand_path('../../test_helper', __FILE__)

class IssueQueryPatchTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values

  RedmineHelpdesk::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,
                                                                                                                   ])

  RedmineHelpdesk::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_helpdesk).directory + '/test/fixtures/', [:journal_messages,
                                                                                                                             :helpdesk_tickets])


  def test_issues_with_company_filter
    # Equals
    @query = IssueQuery.new(:name => '_', :filters => { 'customer_company' => {:operator => '=', :values => ['Domoway']}})
    assert_equal [1,2,5].sort, @query.issues.map(&:id).sort
    # Contains
    @query = IssueQuery.new(:name => '_', :filters => { 'customer_company' => {:operator => '~', :values => ['omowa']}})
    assert_equal [1,2,5].sort, @query.issues.map(&:id).sort
    # Is not null
    @query = IssueQuery.new(:name => '_', :filters => { 'customer_company' => {:operator => '*', :values => ['']}})
    assert_equal [1,2,5].sort, @query.issues.map(&:id).sort

    # Is null
    Contact.find(3).update_attribute(:company, 'company_name')
    @query = IssueQuery.new(:name => '_', :filters => { 'customer_company' => {:operator => '!*', :values => ['']}})
    assert (not @query.issues.any?)
  end

end
