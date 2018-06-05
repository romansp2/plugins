# encoding: utf-8
#
# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.

module ChecklistsHelper

  def link_to_remove_checklist_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", options)
  end

  def new_object(f, association)
    @new_object ||= f.object.class.reflect_on_association(association).klass.new
  end

  def fields(f, association)
    @fields ||= f.fields_for(association, new_object(f, association), :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
  end

  def new_or_show(f)
    if f.object.new_record?
      if f.object.subject.present?
        "show"
      else
        "new"
      end
    else
      "show"
    end
  end

  def done_css(f)
    if f.object.is_done
      "is-done-checklist-item"
    else
      ""
    end
  end
  def template_options_for_select(project = nil)
    scoped = ChecklistTemplate.visible
    scoped = scoped.in_project_and_global(project) if project.present?
    templates = scoped.eager_load(:category).to_a
    without_category = templates.select{ |x| x.category.nil? }.map{ |x| [x.name, x.id, {'data-template-items' => x.template_items}] }
    with_category = templates.select{ |x| x.category }
    options_for_select(
      [[l(:label_select_template), '']] + without_category
    ) +
    grouped_options_for_select(
        with_category.group_by{ |x| x.category.try(:name) }.
        map{ |k,v| [ k, v.map{ |x| [ x.name, x.id, {'data-template-items' => x.template_items} ] } ] }
    )
  end

end
