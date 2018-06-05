# This file is a part of Redmin CMS (redmine_cms) plugin,
# CMS plugin for redmine
#
# Copyright (C) 2011-2016 RedmineUP
# http://www.redmineup.com/
#
# redmine_cms is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_cms is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_cms.  If not, see <http://www.gnu.org/licenses/>.

require "uri"
require "json"
require "date"
require "liquid"

module RedmineCrm
  module Liquid
    module Filters
      module Base

        def textilize(input)
          RedCloth3.new(input).to_html
        end

        def default(input, value)
          input.blank? ? value : input
        end

        def underscore(input)
          input.to_s.gsub(' ', '_').gsub('/', '_').underscore
        end

        def dasherize(input)
          input.to_s.gsub(' ', '-').gsub('/', '-').dasherize
        end

        def shuffle(array)
          array.to_a.shuffle
        end

        def random(input)
          rand(input.to_i)
        end

        # example:
        #   {{ "http:://www.example.com?key=hello world" | encode }}
        #
        #   => http%3A%3A%2F%2Fwww.example.com%3Fkey%3Dhello+world
        def encode(input)
          Rack::Utils.escape(input)
        end

        # example:
        #   {{ today | plus_days: 2 }}
        def plus_days(input, distanse)
          return '' if input.nil?
          days = distanse.to_i
          input.to_date + days.days rescue 'Invalid date'
        end

        # example:
        #   {{ today | date_range: '2015-12-12' }}
        def date_range(input, distanse)
          return '' if input.nil?
          (input.to_date - distanse.to_date).to_i rescue 'Invalid date'
        end


        # example:
        #   {{ now | utc }}
        def utc(input)
          return '' if input.nil?
          input.to_time.utc rescue 'Invalid date'
        end

        def modulo(input, operand)
          apply_operation(input, operand, :%)
        end

        def round(input, n = 0)
          result = to_number(input).round(to_number(n))
          result = result.to_f if result.is_a?(BigDecimal)
          result = result.to_i if n == 0
          result
        end

        def ceil(input)
          to_number(input).ceil.to_i
        end

        def floor(input)
          to_number(input).floor.to_i
        end

        def currency(input, currency_code='USD')
          price_to_currency(input, currency_code, :converted => false)
        end

        def call_method(input, method_name)
          if input.respond_to?(method_name)
            input.method(method_name).call
          end
        end

        def custom_field(input, field_name)
          if input.respond_to?(:custom_fields)
            input.custom_fields[field_name]
          end
        end

        def attachment(input, file_name)
          if input.respond_to?(:attachments)
            if input.attachments.is_a?(Hash)
              attachment = input.attachments[file_name]
            else
              attachment = input.attachments.detect{|a| a.file_name == file_name}
            end
            AttachmentDrop.new attachment if attachment
          end
        end

        protected

        # Convert an array of properties ('key:value') into a hash
        # Ex: ['width:50', 'height:100'] => { :width => '50', :height => '100' }
        def args_to_options(*args)
          options = {}
          args.flatten.each do |a|
            if (a =~ /^(.*):(.*)$/)
              options[$1.to_sym] = $2
            end
          end
          options
        end

        # Write options (Hash) into a string according to the following pattern:
        # <key1>="<value1>", <key2>="<value2", ...etc
        def inline_options(options = {})
          return '' if options.empty?
          (options.stringify_keys.sort.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ') << ' '
        end

        def sort_input(input, property, order)
          input.sort do |apple, orange|
            apple_property = item_property(apple, property)
            orange_property = item_property(orange, property)

            if !apple_property.nil? && orange_property.nil?
              - order
            elsif apple_property.nil? && !orange_property.nil?
              + order
            else
              apple_property <=> orange_property
            end
          end
        end

        def time(input)
          case input
          when Time
            input.clone
          when Date
            input.to_time
          when String
            Time.parse(input) rescue Time.at(input.to_i)
          when Numeric
            Time.at(input)
          else
            raise Errors::InvalidDateError,
              "Invalid Date: '#{input.inspect}' is not a valid datetime."
          end.localtime
        end

        def groupable?(element)
          element.respond_to?(:group_by)
        end

        def item_property(item, property)
          if item.respond_to?(:to_liquid)
            item.to_liquid[property.to_s]
          elsif item.respond_to?(:data)
            item.data[property.to_s]
          else
            item[property.to_s]
          end
        end

        def as_liquid(item)
          case item
          when Hash
            pairs = item.map { |k, v| as_liquid([k, v]) }
            Hash[pairs]
          when Array
            item.map { |i| as_liquid(i) }
          else
            if item.respond_to?(:to_liquid)
              liquidated = item.to_liquid
              # prevent infinite recursion for simple types (which return `self`)
              if liquidated == item
                item
              else
                as_liquid(liquidated)
              end
            else
              item
            end
          end
        end

      end
      ::Liquid::Template.register_filter(RedmineCrm::Liquid::Filters::Base)

    end
  end
end
