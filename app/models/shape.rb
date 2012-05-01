class Shape < ActiveRecord::Base
  belongs_to :shape_set
  has_many :high_meshes, :class_name => 'Mesh', :foreign_key => 'back_shape_id', :dependent => :destroy
  has_many :low_meshes, :class_name => 'Mesh', :foreign_key => 'front_shape_id', :dependent => :destroy
  has_and_belongs_to_many :region_definitions
  
  def meshes
    self.low_meshes + self.high_meshes
  end
  
end
