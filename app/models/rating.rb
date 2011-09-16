class Rating < ActiveRecord::Base
  belongs_to :direction, :foreign_key => 'scope_id'
  belongs_to :period
  belongs_to :division
  belongs_to :block
  belongs_to :subblock
  belongs_to :factor
  set_table_name "indexes"
end