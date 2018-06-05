# This file is a part of Redmin Agile (redmine_agile) plugin,
# Agile board plugin for redmine
#
# Copyright (C) 2011-2016 RedmineCRM
# http://www.redminecrm.com/
#
# redmine_agile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_agile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_agile.  If not, see <http://www.gnu.org/licenses/>.

module RedmineAgile
  class WorkBurnupChart < BurnupChart

    def initialize(data_scope, options={})
      super data_scope, options
      @style_sheet = "#{Redmine::Utils.relative_url_root}/plugin_assets/redmine_agile/stylesheets/charts/work_burnup.css"
      if @estimated_unit == 'hours'
        @y_title = l(:label_agile_charts_number_of_hours)
        @graph_title = l(:label_agile_charts_work_burnup_hours)
      else
        @y_title = l(:label_agile_charts_number_of_story_points)
        @graph_title = l(:label_agile_charts_work_burnup_sp)
      end
    end

    protected

    def calc_data
      if use_subissue_done_ratio && @estimated_unit == 'hours'
        data_scope = @data_scope.
          where("#{Issue.table_name}.rgt - #{Issue.table_name}.lft = 1")
      else
        data_scope = @data_scope
      end
      if @estimated_unit == 'hours'
          all_issues = data_scope.
          where("#{Issue.table_name}.estimated_hours IS NOT NULL").
          eager_load([:journals, :status, {:journals => {:details => :journal}}])
        cumulative_total_hours = data_scope.
          sum("#{Issue.table_name}.estimated_hours").to_f
          @cumulative_data = cumulative_hours_by_period(data_scope)
      else
        all_issues = data_scope.
          where("#{AgileData.table_name}.story_points IS NOT NULL").
          joins(:agile_data).
          eager_load([:journals, :status, {:journals => {:details => :journal}}])
        cumulative_total_hours = data_scope.
          joins(:agile_data).
          sum("#{AgileData.table_name}.story_points").to_f
          @cumulative_data = cumulative_story_points_by_period(data_scope)
      end

      data = chart_dates_by_period.select{|d| d <= Date.today}.map do |date|
        issues = all_issues.select do |issue|
          issue.created_on.localtime.to_date <= date
        end
        cumulative_total_hours_left, total_hours_done = date_effort(issues, date)[1..2]
        total_hours_done
      end
      @data = [first_period_effort(all_issues, chart_dates_by_period.first)[0][2]] + data
      @cumulative_data = @cumulative_data.first(@data.count) if @cumulative_data.count > @data.count
      @data
    end


    private

    def cumulative_hours_by_period(data_scope)
      data = [0] * chart_dates_by_period.count
      data_scope.
        where("#{Issue.table_name}.created_on >= ?", @date_from).
        where("#{Issue.table_name}.created_on < ?", @date_to.to_date + 1).
        where("#{Issue.table_name}.created_on IS NOT NULL").
        group("#{Issue.table_name}.created_on").
        sum(:estimated_hours).each do |c|
          next if c.first.localtime.to_date > @date_to.to_date
          period_num = ((@date_to.to_date - c.first.localtime.to_date).to_i / @scale_division).to_i
          data[period_num] += c.last unless data[period_num].blank?
        end

      total_estimated_hours = data_scope.
        where("#{Issue.table_name}.created_on < ?", @date_from).
        sum(:estimated_hours)
      first_date_estimated_hours = data_scope.
        where("#{Issue.table_name}.created_on < ?", @date_from).
        sum(:estimated_hours)
      ([first_date_estimated_hours] +  data.reverse.map{|x| total_estimated_hours += x})

    end

    def first_period_effort(issues_scope, start_date)
      issues = issues_scope.select do |issue|
        issue.created_on.localtime.to_date <= start_date
      end
      total_left, cumulative_left, total_done = date_effort(issues, start_date - 1)
      [[total_left, cumulative_left, total_done]]
    end

    def cumulative_story_points_by_period(data_scope)
      data = [0] * @period_count
      data_scope.
        where("#{Issue.table_name}.created_on >= ?", @date_from).
        where("#{Issue.table_name}.created_on < ?", @date_to.to_date + 1).
        where("#{Issue.table_name}.created_on IS NOT NULL").
        group("#{Issue.table_name}.created_on").
        joins(:agile_data).
        sum("#{AgileData.table_name}.story_points").each do |c|
          next if c.first.localtime.to_date > @date_to.to_date
          period_num = ((@date_to.to_date - c.first.localtime.to_date).to_i / @scale_division).to_i
          data[period_num] += c.last.to_i unless data[period_num].blank?
        end

      total_estimated_hours = data_scope.
        where("#{Issue.table_name}.created_on < ?", @date_from).
        joins(:agile_data).
        sum("#{AgileData.table_name}.story_points").to_i
        # to_i is necessary for old version of rails
        # because sum return a string if a result equal 0

      first_date_estimated_hours = data_scope.
        where("#{Issue.table_name}.created_on < ?", @date_from).
        joins(:agile_data).
        sum("#{AgileData.table_name}.story_points").to_i
      [first_date_estimated_hours] +  data.reverse.map{ |x| total_estimated_hours += x }

    end

  end
end
