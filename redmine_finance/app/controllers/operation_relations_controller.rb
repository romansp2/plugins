# This file is a part of Redmine Finance (redmine_finance) plugin,
# simple accounting plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_finance is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_finance is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_finance.  If not, see <http://www.gnu.org/licenses/>.

class OperationRelationsController < ApplicationController
  unloadable

  before_filter :find_operation, :find_project_from_association, :authorize, :only => [:index, :create]
  before_filter :find_relation, :except => [:index, :create]

  accept_api_auth :index, :show, :create, :destroy

  def index
    @relations = @operation.relations

    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  end

  def show
    raise Unauthorized unless @relation.visible?

    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  end

  def create
    @relation = OperationRelation.new(params[:relation])
    @relation.operation_source = @operation
    @relation.relation_type = 0
    saved = @relation.save

    respond_to do |format|
      format.html { redirect_to :controller => 'operations', :action => 'show', :id => @operation }
      format.js {
        @relations = @operation.relations.select {|r| r.other_operation(@operation) && r.other_operation(@operation).visible? }
      }
      format.api {
        if saved
          render :action => 'show', :status => :created, :location => relation_url(@relation)
        else
          render_validation_errors(@relation)
        end
      }
    end
  end

  def destroy
    raise Unauthorized unless @relation.deletable?
    @relation.destroy

    respond_to do |format|
      format.html { redirect_to :back } # TODO : does this really work since @operation is always nil? What is it useful to?
      format.js
      format.api  { render_api_ok }
    end
  end

private
  def find_operation
    @operation = @object = Operation.find(params[:operation_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_relation
    @relation = OperationRelation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
