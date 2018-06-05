class HelpdeskDataCollectorBusiestTime
  MAX_WEIGHT = 200

  RESPONSE_INTERVALS = { '15_18h' => [15, 18],
                         '18_21h' => [18, 21],
                         '21_0h' => [21, 0],
                         '0_3h' => [0, 3],
                         '3_7h' => [3, 7],
                         '7_10h' => [7, 10],
                         '10_13h' => [10, 13],
                         '13_15h' => [13, 15] }

  def columns
    @columns ||= collect_columns
  end

  def issue_weight
    @issue_weight ||= (MAX_WEIGHT.to_f / columns.map { |column| column[:issues_count] } .sort.last).ceil
  end

  def contacts_count
    contacts.count
  end

  def previous_contacts_count
    previous_contacts.count
  end

  def total_contacts_count_progress
    return 0 if previous_contacts_count.zero?
    calculate_progress(previous_issues_count, issues_count)
  end

  def issues_count
    @issues_count ||= @issues.count
  end

  def previous_issues_count
    @previous_issues_count ||= @previous_issues.count
  end

  def issue_count_progress
    return 0 if previous_issues_count.zero?
    calculate_progress(previous_issues_count, issues_count)
  end

  private

  def initialize(query)
    @query = query
    @issues = @query.issues
    @previous_issues = previous_query.issues
  end

  def collect_columns
    columns = []
    RESPONSE_INTERVALS.each do |interval_name, interval_hours|
      interval_issues_count = find_issues_count(interval_hours)
      columns << { :name => interval_name, :issues_count => interval_issues_count,
                   :issues_percent => ((interval_issues_count.to_f / issues_count.to_f) * 100).round(2) }
    end
    columns
  end

  def find_issues_count(interval)
    interval_start = interval.first
    interval_end = interval.last - 1 < 0 ? 23 : interval.last - 1
    interval_issues = @issues.each.select do |issue|
      issue_time = timezone ? issue.created_on.in_time_zone(timezone) : issue.created_on.localtime
      interval_start <= issue_time.hour && issue_time.hour <= interval_end
    end
    interval_issues.count
  end

  def timezone
    @timezone ||= User.current.time_zone
  end

  def previous_query
    return if @query[:filters].nil? || @query[:filters]['created_on'].nil? || @query[:filters]['created_on'][:operator].nil?
    return @previous_query if @previous_query

    previous_operator = ['pre_', @query[:filters]['created_on'][:operator]].join
    previous_filters = @query[:filters].merge('created_on' => { :operator => previous_operator, :values => [Date.today.to_s] })
    @previous_query = HelpdeskReportsBusiestTimeQuery.new(:name => '_', :project => @query.project, :filters => previous_filters)
    @previous_query
  end

  def contacts
    return @contacts if @contacts
    condition = @query.send('sql_for_field', nil, @query.filters['created_on'][:operator], nil, 'contacts', 'created_on')
    @contacts = Contact.where(:id => @issues.joins(:contacts).map(&:contact_ids).flatten).where(condition)
  end

  def previous_contacts
    return @previous_contacts if @previous_contacts
    condition = @query.send('sql_for_field', nil, @previous_query.filters['created_on'][:operator], nil, 'contacts', 'created_on')
    @previous_contacts = Contact.where(:id => @previous_issues.joins(:contacts).map(&:contact_ids).flatten).where(condition)
  end

  def contacts_created_on_interval(issues)
    ordered_issues = issues.order('created_on')
    [ordered_issues.first.created_on, ordered_issues.last.created_on]
  end

  def calculate_progress(before, now)
    progress =
      if before.to_f > now.to_f
        100 - (now.to_f * 100 / before.to_f)
      else
        (100 - (before.to_f * 100 / now.to_f)) * -1
      end
    progress.round
  end
end
