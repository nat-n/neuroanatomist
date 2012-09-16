class Shape < ActiveRecord::Base
  belongs_to :shape_set
  has_many :high_meshes, :class_name => 'Mesh', :foreign_key => 'back_shape_id', :dependent => :destroy
  has_many :low_meshes, :class_name => 'Mesh', :foreign_key => 'front_shape_id', :dependent => :destroy
  has_and_belongs_to_many :region_definitions
  
  def hash_partial
    Hash[
      id:             id,
      volume_value:   volume_value,
      name:           name,
      meshes:         meshes.map(&:id)
    ]
  end
  
  def has_definition_for region
    region_definitions.each do |region_definition|
      return true if region_definition.region == region
    end
    return false
  end
  
  def meshes
    self.low_meshes + self.high_meshes
  end
  
  def name
    self.label
  end
  
end
