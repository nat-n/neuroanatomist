class Region < ActiveRecord::Base
  belongs_to  :thing
  has_and_belongs_to_many :region_sets
  has_many :region_definitions
  has_many :shape_sets, :through => :region_definitions
  has_many :region_styles
  has_many :perspectives, :through => :region_styles
  
  alias :definitions :region_definitions
  
  def definition_for shape_set
    (definitions = region_definitions.select{ |x| x.shape_set_id == shape_set.id }).empty? ? false : definitions[0]
  end
  
  def label
    attributes["label"] or name
  end
  
  def has_label?
    attributes["label"] ? true : false
  end
      
end
