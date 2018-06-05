class IssueBlock < ActiveRecord::Base
  unloadable
  attr_accessor :only_watchers, :all_axcept_comment
  attr_accessible :only_watchers, :all_axcept_comment
  

  class PermissionsAttributeCoder
    def self.load(str)
      str.to_s.scan(/:([a-z0-9_]+)/).flatten.map(&:to_sym)
    end

    def self.dump(value)
      YAML.dump(value)
    end
  end
  

  belongs_to :issue
  accepts_nested_attributes_for :issue

  serialize :permissions, ::IssueBlock::PermissionsAttributeCoder

  def all_actions=(only)
    if only
      (permissions << :all_actions) unless permissions.include?(:all_actions) 
    else
      permissions.delete_if{|perm| perm == :all_actions}
    end
  end
  def all_actions
    (return true) if permissions.blank?
    permissions.include?(:all_actions) 
  end
  def only_watchers=(only)
    #self.permissions = [] unless permissions.is_a?(Array)
    if only
      (permissions << :only_watchers) unless permissions.include?(:only_watchers) 
    else
      permissions.delete_if{|perm| perm == :only_watchers}
    end
  end
  def only_watchers
    permissions.include?(:only_watchers) 
  end

  def all_axcept_comment=(only)
    if only
      (permissions << :all_axcept_comment) unless permissions.include?(:all_axcept_comment) 
    else
      permissions.delete_if{|perm| perm == :all_axcept_comment}
    end
  end
  def all_axcept_comment
    permissions.include?(:all_axcept_comment) 
  end


  def permissions=(perms)
    perms = perms.collect {|p| p.to_sym unless p.blank? }.compact.uniq if perms
    write_attribute(:permissions, perms)
  end



  def add_permission!(*perms)
    self.permissions = [] unless permissions.is_a?(Array)

    permissions_will_change!
    perms.each do |p|
      p = p.to_sym
      permissions << p unless permissions.include?(p)
    end
    save!
  end

  def remove_permission!(*perms)
    return unless permissions.is_a?(Array)
    permissions_will_change!
    perms.each { |p| permissions.delete(p.to_sym) }
    save!
  end

  # Returns true if the role has the given permission
  def has_permission?(perm)
    !permissions.nil? && permissions.include?(perm.to_sym)
  end

  def <=>(role)
    if role
      if builtin == role.builtin
        position <=> role.position
      else
        builtin <=> role.builtin
      end
    else
      -1
    end
  end
end
