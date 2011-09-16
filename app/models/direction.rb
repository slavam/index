class Direction < ActiveRecord::Base
  has_many :blocks, :foreign_key => 'scope_id'
  has_many :ratings, :foreign_key => 'scope_id'
  set_table_name "scopes"
end