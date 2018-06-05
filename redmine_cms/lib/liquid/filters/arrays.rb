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

module RedmineCrm
  module Liquid
    module Filters
      module Arrays
        include ApplicationHelper
        include Rails.application.routes.url_helpers

        # Convert the input into json string
        #
        # input - The Array or Hash to be converted
        #
        # Returns the converted json string
        def jsonify(input)
          as_liquid(input).to_json
        end

        # Group an array of items by a property
        #
        # input - the inputted Enumerable
        # property - the property
        #
        # Returns an array of Hashes, each looking something like this:
        #  {"name"  => "larry"
        #   "items" => [...] } # all the items where `property` == "larry"
        def group_by(input, property)
          if groupable?(input)
            input.group_by { |item| item_property(item, property).to_s }
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

        # Filter an array of objects
        #
        # input - the object array
        # property - property within each object to filter by
        # value - desired value
        #
        # Returns the filtered array of objects
        def where(input, property, value, operator='==')
          return input unless input.respond_to?(:select)
          input = input.values if input.is_a?(Hash)
          if operator == '=='
            input.select do |object|
              Array(item_property(object, property)).map(&:to_s).include?(value.to_s)
            end || []
          elsif operator == '<>'
            input.select do |object|
              !Array(item_property(object, property)).map(&:to_s).include?(value.to_s)
            end || []
          elsif operator == '>'
            input.select do |object|
              item_property(object, property) > value
            end || []
          elsif operator == '<'
            input.select do |object|
              item_property(object, property) < value
            end || []
          elsif operator == 'match'
            input.select do |object|
              Array(item_property(object, property)).map(&:to_s).any?{|i| i.match(value.to_s)}
            end || []
          else
            []
          end
        end

        # Filter an array of objects by tags
        #
        # input - the object array
        # tags - quoted tags list divided by comma
        # match - (all- defaut, any, exclude)
        #
        # Returns the filtered array of objects
        def tagged_with(input, tags, match='all')
          return input unless input.respond_to?(:select)
          input = input.values if input.is_a?(Hash)
          tag_list = input.is_a?(Array) ? tags.sort : tags.split(',').map(&:strip).sort
          case match
          when "all"
            input.select do |object|
              object.respond_to?(:tag_list) &&
              (tag_list - Array(item_property(object, 'tag_list')).map(&:to_s).sort).empty?
            end || []
          when "any"
            input.select do |object|
              object.respond_to?(:tag_list) &&
              (tag_list & Array(item_property(object, 'tag_list')).map(&:to_s).sort).any?
            end || []
          when "exclude"
            input.select do |object|
              object.respond_to?(:tag_list) &&
              (tag_list & Array(item_property(object, 'tag_list')).map(&:to_s).sort).empty?
            end || []
          else
            []
          end
        end

        # Sort an array of objects
        #
        # input - the object array
        # property - property within each object to filter by
        # nils ('first' | 'last') - nils appear before or after non-nil values
        #
        # Returns the filtered array of objects
        def sort(input, property = nil, nils = "first")
          if input.nil?
            raise ArgumentError, "Cannot sort a null object."
          end
          if property.nil?
            input.sort
          else
            if nils == "first"
              order = - 1
            elsif nils == "last"
              order = + 1
            else
              raise ArgumentError, "Invalid nils order: " \
                "'#{nils}' is not a valid nils order. It must be 'first' or 'last'."
            end

            sort_input(input, property, order)
          end
        end

        def pop(array, input = 1)
          return array unless array.is_a?(Array)
          new_ary = array.dup
          new_ary.pop(input.to_i || 1)
          new_ary
        end

        def push(array, input)
          return array unless array.is_a?(Array)
          new_ary = array.dup
          new_ary.push(input)
          new_ary
        end

        def shift(array, input = 1)
          return array unless array.is_a?(Array)
          new_ary = array.dup
          new_ary.shift(input.to_i || 1)
          new_ary
        end

        def unshift(array, input)
          return array unless array.is_a?(Array)
          new_ary = array.dup
          new_ary.unshift(input)
          new_ary
        end

        private



      end # module ArrayFilters
    end
  end

  ::Liquid::Template.register_filter(RedmineCrm::Liquid::Filters::Arrays)
end
