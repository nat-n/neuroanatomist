class Decomposition < ActiveRecord::Base
  belongs_to :super_region, :class_name => 'Region', :foreign_key => 'region_id'
  has_and_belongs_to_many :sub_regions, :class_name => 'Region'
  validates_presence_of :super_region, :description
  
  def is_compatible_with shape_set
    
  end
  
end
