class CmsContentVersion < ActiveRecord::Base
  unloadable

  attr_accessible :author, :content, :version, :comments

  belongs_to :versionable, :polymorphic => true
  belongs_to :author, :class_name => "User"

  def current_version?
    versionable.version == self.version
  end

  # Returns the previous version or nil
  def previous
    @previous ||= CmsContentVersion.
      reorder('version DESC').
      includes(:author).
      where("versionable_type = ? AND versionable_id = ? AND version < ?",
        versionable.class, versionable.id, version).first
  end

end
