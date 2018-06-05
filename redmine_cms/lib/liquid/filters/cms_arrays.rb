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

module RedmineCms
  module Liquid
    module Filters
      module CmsArrays

        # Filter an array of objects
        #
        # input - the object array
        # field - field within each object to filter by
        # value - desired value
        #
        # Returns the filtered array of objects
        def where_field(input, field, value, operator='==')
          return input unless input.respond_to?(:select)
          input = input.values if input.is_a?(Hash)
          values = value.is_a?(Array) ? value : value.to_s.split(',')
          if operator == '=='
            input.select do |object|
              object.respond_to?(:fields)  &&
              object.fields[field].to_s == value.to_s.strip
            end || []
          elsif operator == '<>'
            input.select do |object|
              object.respond_to?(:fields)  &&
              object.fields[field] != value.to_s.strip
            end || []
          elsif operator == '>'
            input.select do |object|
              object.respond_to?(:fields)  &&
              object.fields[field].to_i > value.to_i
            end || []
          elsif operator == '<'
            input.select do |object|
              object.respond_to?(:fields)  &&
              object.fields[field].to_i < value.to_i
            end || []
          elsif operator == 'match'
            input.select do |object|
              object.respond_to?(:fields)  &&
              object.fields[field].to_s.match(value.to_s)
            end || []
          elsif operator == 'all'
            input.select do |object|
              object.respond_to?(:fields)  &&
              (values - object.fields[field].to_s.split(',')).empty?
            end || []
          elsif operator == 'any'
            input.select do |object|
              object.respond_to?(:fields)  &&
              (values & object.fields[field].to_s.split(',')).any?
            end || []
          elsif operator == 'exclude'
            input.select do |object|
              object.respond_to?(:fields)  &&
              (values & object.fields[field].to_s.split(',')).empty?
            end || []
          else
            []
          end
        end

        # Group an array of pages by a field value
        #
        # input - the pages Enumerable
        # field - the field name
        #
        # Returns an array of Hashes, each looking something like this:
        #  {"name"  => "larry"
        #   "items" => [...] } # all the items where `property` == "larry"
        def group_by_field(input, field)
          if groupable?(input)
            input.group_by { |item| item.fields[field].to_s }
              .each_with_object([]) do |item, array|
                array << {
                  "name"  => item.first,
                  "items" => item.last,
                  "size"  => item.last.size
                }
              end
          else
            input
          end
        end

      end # module ArrayFilters
    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::CmsArrays)
end
