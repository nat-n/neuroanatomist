class Region < ActiveRecord::Base
  belongs_to  :thing
  has_and_belongs_to_many :super_compositions, :class_name => 'Decomposition'
  has_many :decompositions, :dependent => :destroy
  has_many :sub_regions, :through => :decompositions
  has_many :region_definitions, :dependent => :destroy
  has_many :shape_sets, :through => :region_definitions
  has_many :region_styles, :dependent => :destroy
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
