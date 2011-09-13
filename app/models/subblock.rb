class Subblock < ActiveRecord::Base
  belongs_to :block, :foreign_key => 'group_id'
  has_many :factors, :foreign_key => 'subgroup_id'
  set_table_name "subgroups"
end