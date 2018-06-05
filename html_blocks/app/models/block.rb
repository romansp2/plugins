class Block < ActiveRecord::Base
  validates :address, length: { maximum: 20,
                            too_long: l('html_block.activerecord.errors.length', count: count) }
  validates :text, :address, :link_type, presence: true

  enum link_type: [ :link, :regexp ]
end
