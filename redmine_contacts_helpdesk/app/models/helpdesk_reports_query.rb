class HelpdeskReportsQuery < Query

  self.queried_class = Issue
  operators_by_filter_type[:time_interval] = ['t', 'ld', 'w', 'l2w', 'm', 'lm', 'y']

  def initialize_available_filters
    add_available_filter 'created_on', :type => :time_interval, :name => l(:label_helpdesk_filter_time_interval)
    author_values = collect_answered_users.collect { |user| [user.name, user.id.to_s] }
    add_available_filter 'staff', :type => :list, :name => l(:field_assigned_to), :values => author_values
  end

  def build_from_params(params)
    if params[:fields] || params[:f]
      self.filters = {}
      add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
    else
      available_filters.keys.each do |field|
        add_short_filter(field, params[field]) if params[field]
      end
    end

    self
  end

  def issues(options = {})
    scope = issue_scope.eager_load((options[:include] || []).uniq).
                        where(options[:conditions]).
                        limit(options[:limit]).
                        offset(options[:offset])
    scope
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

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

  def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter = false)
    sql = ''
    case operator
    when 'pre_t'
      sql = date_clause_selector(db_table, db_field, 1.day.ago.beginning_of_day, 1.day.ago, is_custom_filter)
    when 'pre_ld'
      sql = date_clause_selector(db_table, db_field, 2.day.ago.beginning_of_day, 2.day.ago.end_of_day, is_custom_filter)
    when 'pre_w'
      sql = date_clause_selector(db_table, db_field, 7.day.ago.beginning_of_week, 7.days.ago, is_custom_filter)
    when 'pre_l2w'
      sql = date_clause_selector(db_table, db_field, 4.weeks.ago.beginning_of_week, 3.weeks.ago.end_of_week, is_custom_filter)
    when 'pre_m'
      sql = date_clause_selector(db_table, db_field, 1.month.ago.beginning_of_month, 1.month.ago, is_custom_filter)
    when 'pre_lm'
      sql = date_clause_selector(db_table, db_field, 2.month.ago.beginning_of_month, 2.month.ago.end_of_month, is_custom_filter)
    when 'pre_y'
      sql = date_clause_selector(db_table, db_field, 1.year.ago.beginning_of_year, 1.year.ago, is_custom_filter)
    end
    sql = super(field, operator, value, db_table, db_field, is_custom_filter) if sql.blank?

    return sql
  end

  def date_clause_selector(table, field, from, to, is_custom_filter)
    return date_clause(table, field, from, to) if Redmine::VERSION.to_s < '3.0'
    date_clause(table, field, from, to, is_custom_filter)
  end

  def issue_scope
    Issue.visible.joins(:project).where(statement)
  end

end
