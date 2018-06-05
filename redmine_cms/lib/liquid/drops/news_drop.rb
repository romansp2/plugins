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

class NewssDrop < Liquid::Drop

  def initialize(newss)
    @newss = newss
  end

  def before_method(id)
    news = @newss.where(:id => id).first || News.new
    NewsDrop.new news
  end

  def last
    NewsDrop.new News.last
  end

  def all
    @all ||= @newss.map do |news|
      NewsDrop.new news
    end
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @newss.size
  end

end


class NewsDrop < Liquid::Drop

  delegate :id, :title, :summary, :description, :visible?, :commentable?, :to => :@news

  def initialize(news)
    @news = news
  end

  def author
    UserDrop.new @news.author
  end

end

