class Factor < ActiveRecord::Base
  belongs_to :factor_description
  belongs_to :subblock, :foreign_key => 'subgroup_id'
  has_many :factor_weights
  has_many :articles  
#  has_many :indexes
end