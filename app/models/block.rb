class Block < ActiveRecord::Base
  belongs_to :direction, :foreign_key => 'scope_id'
  has_many :subblocks, :foreign_key => 'group_id'
  set_table_name "groups"
end