class RegionDefinition < ActiveRecord::Base
  has_and_belongs_to_many :shapes
  belongs_to  :shape_set
  belongs_to  :region
  validates   :shape_set, :presence => true
  validates   :region, :presence => true
  validate    :only_one_definition_per_region, :message => "A region may be defined only once per shape set"
  
  
  
  def only_one_definition_per_region
    existing_definitions = RegionDefinition.where("region_id = #{region.id} and shape_set_id = #{shape_set.id}")
    unless existing_definitions.empty? or (existing_definitions.size==1 and existing_definitions.first.id = id)      
      errors.add :region, "A region may be defined only once per shape set"
      return false
    end
    return true
  end
end
