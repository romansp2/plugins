class HelpdeskReportsFirstResponseQuery < HelpdeskReportsQuery
  def sql_for_staff_field(_field, operator, value)
    issue_table = Issue.table_name
    journal_table = Journal.table_name
    compare = operator == '=' ? 'IN' : 'NOT IN'
    staff_ids = value.join(',')
    "#{issue_table}.id IN(SELECT #{issue_table}.id FROM #{issue_table} INNER JOIN #{journal_table} ON #{journal_table}.journalized_id = #{issue_table}.id AND #{journal_table}.journalized_type = 'Issue' WHERE (#{journal_table}.user_id #{compare} (#{staff_ids})))"
  end

  private

  def collect_answered_users
    return [] unless project
    user_ids = Issue.joins(:project).
      joins(:journals).
      joins(:journals => :journal_message).
      visible.uniq.
      pluck(:assigned_to_id).compact
    User.where(:id => user_ids)
  end
end
