class HelpdeskDataCollectorManager
  def initialize(report)
    @report = report
  end

  def collect_data(query)
    case @report
    when 'first_response_time'
      HelpdeskDataCollectorFirstResponse.new(query)
    when 'busiest_time_of_day'
      HelpdeskDataCollectorBusiestTime.new(query)
    end
  end
end
