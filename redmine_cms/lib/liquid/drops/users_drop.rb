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

class UsersDrop < Liquid::Drop

  def initialize(users)
    @users = users
  end

  def before_method(login)
    user = @users.where(:login => login).first || User.new
    UserDrop.new user
  end

  def current
    UserDrop.new User.current
  end

  def all
    @all ||= @users.map do |user|
      UserDrop.new user
    end
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @users.size
  end

end


class UserDrop < Liquid::Drop

  delegate :id, :login, :name, :firstname, :lastname, :mail, :active?, :admin?, :logged?, :language, :to => :@user

  def initialize(user)
    @user = user
  end

  def avatar
    ApplicationController.helpers.avatar(@user)
  end

  def permissions
    roles = @user.memberships.collect {|m| m.roles}.flatten.uniq
    roles << (@user.logged? ? Role.non_member : Role.anonymous)
    roles.map(&:permissions).flatten.uniq.map(&:to_s)
  end

  def editor?
    RedmineCms.allow_edit?(@user)
  end

  def groups
    @user.groups.map(&:name)
  end

  def projects
    ProjectsDrop.new @user.memberships.map(&:project).flatten.select(&:visible?).uniq
  end

end

