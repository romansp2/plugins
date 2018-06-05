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

class Operation < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  attr_accessible :amount, :description, :account_id, :category_id, :operation_date, :is_approved, :contact_id, :assigned_to_id, :income, :custom_field_values

  belongs_to :account
  belongs_to :contact
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :category, :class_name => "OperationCategory", :foreign_key => "category_id"
  belongs_to :assigned_to, :class_name => 'Principal', :foreign_key => 'assigned_to_id'
  delegate :project, :to => :account, :allow_nil => true
  delegate :currency, :to => :account, :allow_nil => true
  delegate :recipients, :watcher_recipients, :to => :account, :allow_nil => true
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"
  has_many :operation_objects, :dependent => :destroy
  has_many :invoices, :through => :operation_objects, :source => :operationable, :source_type => "Invoice"
  has_many :operations, :through => :operation_objects, :source => :operationable, :source_type => "Deal"
  has_many :relation_sources, :class_name => 'OperationRelation', :foreign_key => 'source_id', :dependent => :delete_all
  has_many :relation_destinations, :class_name => 'OperationRelation', :foreign_key => 'destination_id', :dependent => :delete_all

  scope :visible, lambda {|*args| eager_load({:account => :project}).where(Project.allowed_to_condition(args.first || User.current, :view_finances)) }

  scope :income, lambda { where(:income => true) }
  scope :expense, lambda { where(:income => false) }

  scope :approved, lambda {|arg| arg ? where(:is_approved => true) : where(:is_approved => false) if RedmineFinance.operations_approval?}
  scope :current, lambda { where("#{Operation.table_name}.operation_date <= ?", Time.now) }

  scope :live_search, lambda {|search| where("(#{Operation.table_name}.id = ? OR
                                              LOWER(#{Operation.table_name}.description) LIKE ?)",
                                              search.downcase,
                                              "%" + search.downcase + "%") }

  acts_as_event :datetime => :created_at,
                :url => Proc.new {|o| {:controller => 'operations', :action => 'show', :id => o}},
                :type => Proc.new {|o| o.is_income? ? "icon-operation-income" : "icon-operation-expense"},
                :title => Proc.new {|o| "#{o.category_name} ##{o.id}: #{'-' unless o.is_income? }#{o.amount_to_s}" },
                :description => Proc.new {|o| o.description.to_s }

  if ActiveRecord::VERSION::MAJOR >= 4
    acts_as_activity_provider :type => 'finances',
                              :permission => :view_finances,
                              :timestamp => "#{table_name}.created_at",
                              :author_key => :author_id,
                              :scope => joins(:account => :project)
  else
    acts_as_activity_provider :type => 'finances',
                              :permission => :view_finances,
                              :timestamp => "#{table_name}.created_at",
                              :author_key => :author_id,
                              :find_options => {:include => {:account => :project}}
  end
  if ActiveRecord::VERSION::MAJOR >= 4
    acts_as_searchable :columns => ["#{table_name}.description"],
                       :scope => joins([:account => :project]),
                       :project_key => "#{Project.table_name}.id",
                       :permission => :view_finances,
                       # sort by id so that limited eager loading doesn't break with postgresql
                       :date_column => "operation_date"
  else
    acts_as_searchable :columns => ["#{table_name}.description"],
                       :date_column => "#{table_name}.created_at",
                       :include => [:account => :project],
                       :project_key => "#{Project.table_name}.id",
                       :permission => :view_finances,
                       # sort by id so that limited eager loading doesn't break with postgresql
                       :order_column => "#{table_name}.operation_date"
  end
  acts_as_customizable
  acts_as_attachable :view_permission => :view_finances
  acts_as_priceable :amount

  after_save :save_account_amount
  after_save :send_notification
  after_destroy :save_account_amount

  validates_presence_of :account, :author, :operation_date, :category, :amount
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => false

  safe_attributes 'category_id',
                  'account_id',
                  'contact_id',
                  'operation_date',
                  'amount',
                  'assigned_to_id',
                  'custom_field_values',
                  'custom_fields',
                  'description',
                  'income',
    :if => lambda {|operation, user| operation.new_record? || user.allowed_to?(:edit_operations, operation.project) || user.allowed_to?(:edit_own_operations, operation.project) }
  safe_attributes 'is_approved',
    :if => lambda {|operation, user| user.allowed_to?(:approve_operations, operation.project) || !RedmineFinance.operations_approval?}

  def initialize(attributes=nil, *args)
    super
    self.is_approved = true unless RedmineFinance.operations_approval?
  end

  def relations
    @relations ||= (relation_sources | relation_destinations).sort
  end

  def category_name
    self.category && self.category.name
  end

  def is_income?
    income?
  end

  def amount=(am)
    super am.to_s.gsub(/,/,'.')
  end

  def income
    self.is_income? ? self.amount : 0
  end

  def expense
    self.is_income? ? 0: self.amount
  end

  def amount_with_sign
    s = ""
    s << "-" unless self.is_income?
    s << self.amount_to_s
  end

  def visible?(usr=nil)
    (usr || User.current).allowed_to?(:view_finances, self.project)
  end

  def editable_by?(usr, prj=nil)
    prj ||= @project || self.project
    usr && is_not_locked?(usr, prj) && (usr.allowed_to?(:edit_operations, prj) || (self.author == usr && usr.allowed_to?(:edit_own_operations, prj)))
    # usr && usr.logged? && (usr.allowed_to?(:edit_notes, project) || (self.author == usr && usr.allowed_to?(:edit_own_notes, project)))
  end

  def destroyable_by?(usr, prj=nil)
    prj ||= @project || self.project
    usr && (RedmineFinance.operations_approval? && !self.is_approved? || !RedmineFinance.operations_approval?) && (usr.allowed_to?(:delete_operations, prj) || (self.author == usr && usr.allowed_to?(:edit_own_operations, prj)))
  end

  def commentable?(user=User.current)
    user.allowed_to?(:comment_operations, project)
  end

  def copy_from(arg)
    operation = arg.is_a?(Operation) ? arg : Operation.visible.find(arg)
    self.attributes = operation.attributes.dup.except("id", "operation_date", "created_at", "updated_at")
    self.custom_field_values = operation.custom_field_values.inject({}) {|h,v| h[v.custom_field_id] = v.value; h}
    self
  end

  def operation_date
    zone = User.current.time_zone
    return "" if super.nil?
    zone ? super.in_time_zone(zone) : (super.utc? ? super.localtime : super)
  end

  def operation_time
    operation_date.present? ? operation_date.to_s(:time) : ""
  end

  def all_dependent_operations(except=[])
    except << self
    dependencies = []
    relation_sources.each do |relation|
      if relation.operation_destination && !except.include?(relation.operation_destination)
        dependencies << relation.operation_destination
        dependencies += relation.operation_destination.all_dependent_operations(except)
      end
    end
    dependencies
  end

  def created_on
    created_at
  end

  def to_s
    "#{self.category_name} ##{self.id}: #{'-' unless self.is_income? }#{self.amount_to_s}"
  end

  def contact_country
    self.try(:contact).try(:address).try(:country)
  end

  def contact_city
    self.try(:contact).try(:address).try(:city)
  end

  def self.amount_by_account(approved=true)
    income = Operation.visible.income.current.approved(approved).group(:account_id).sum(:amount)
    expense = Operation.visible.expense.current.approved(approved).group(:account_id).sum(:amount)
    income.merge(expense){|k,val_income,val_expense| val_income - val_expense}
  end

  def self.disapproved_amount(is_disapproved_income, project=nil)
    scope = is_disapproved_income ? income : expense
    scope = scope.eager_load(:account)
    scope = scope.where(:accounts => {:project_id => project.id}) if project
    scope.visible.approved(false).group(:currency).sum(:amount)
  end

  private

  def is_not_locked?(usr, prj)
    RedmineFinance.operations_approval? && (self.is_approved? && usr.allowed_to?(:approve_operations, prj) || !self.is_approved?) ||
    !RedmineFinance.operations_approval?
  end

  def save_account_amount
    if self.account_id_changed?
      Account.find_by_id(self.account_id_was).try(:save)
    end
    # self.account.calculate_amount
    self.account.save
  end

  def save_account_amount_destroy
    # self.account.operations.delete(self)
    # self.account.calculate_amount
    self.account.save
  end

  def send_notification
    FinanceMailer.account_edit(self).deliver if Setting.notified_events.include?('finance_account_updated')
  end

end
