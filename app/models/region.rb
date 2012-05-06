class Region < ActiveRecord::Base
  has_and_belongs_to_many :region_sets
  has_many :region_definitions
  has_many :shape_sets, :through => :region_definitions
  
  alias :definitions :region_definitions
    
  def definition_for shape_set
    (definitions = region_definitions.select{ |x| x.shape_set_id == shape_set.id }).empty? ? false : definitions[0]
  end
    
end
