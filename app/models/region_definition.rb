class RegionDefinition < ActiveRecord::Base
  has_and_belongs_to_many :shapes
  belongs_to  :shape_set
  belongs_to  :region
  validates   :shape_set, :presence => true
  validates   :region, :presence => true
  validate    :only_one_definition_per_region, :message => "A region may be defined only once per shape set"
  
  def self.all_definitions_for_shape_set shape_set
    RegionDefinition.where("shape_set_id = ? and orphaned = ?", shape_set.id, false)
  end
  
  def self.orphans
    RegionDefinition.where "orphaned"
  end
  
  def border_ids
    meshes.map {|m| m.borders(:data).keys }.flatten.uniq
  end
  
  def intersect? other, by=:border
    return false unless self.shape_set == other.shape_set
    case by
      when :border; own, others = self.border_ids, other.border_ids
      when :mesh;   own, others = self.meshes,     other.meshes
      when :shape;  own, others = self.shapes,     other.shapes
      else raise "Unknown intersection type: #{by}"
    end
    (own - others).size != own.size
  end
  
  def compatible_with?
    return false unless self.shape_set == other.shape_set
    !self.shape_intersect? other, :shape
  end
  
  def meshes
    # returns only meshes which are actually used (i.e. excluding internal meshes)
    self.all_meshes.reject { |mesh| ([mesh.back_shape,mesh.front_shape]-shapes).empty? }
  end
  
  def all_meshes
    self.shapes.map {|s| s.meshes }.flatten.uniq
  end
  
  def redundant_meshes
    self.all_meshes.select { |mesh| ([mesh.back_shape,mesh.front_shape]-shapes).empty? }
  end
  
  def only_one_definition_per_region
    existing_definitions = RegionDefinition.where("region_id = #{region.id} and shape_set_id = #{shape_set.id}")
    unless existing_definitions.empty? or (existing_definitions.size==1 and existing_definitions.first.id = id)      
      errors.add :region, "A region may be defined only once per shape set"
      return false
    end
    return true
  end
end
