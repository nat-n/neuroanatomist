class Region < ActiveRecord::Base
  belongs_to  :thing
  has_many :region_definitions
  has_many :shape_sets, :through => :region_definitions
  has_many :region_styles
  has_many :perspectives, :through => :region_styles
  validates_uniqueness_of :name
  
  alias :definitions :region_definitions
  
  def definition_for shape_set
    (definitions = region_definitions.select{ |x| x.shape_set_id == shape_set.id }).empty? ? false : definitions[0]
  end
  
  def name
    attributes["name"] or label
  end
  
  def has_name?
    attributes["name"] ? true : false
  end
      
end
