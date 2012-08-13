class RegionStyle < ActiveRecord::Base
  belongs_to :perspective
  belongs_to :region
  
  def disown
    self.update_attributes :orphaned => true
  end
  
  def update_style params
    updatable = Hash.new
    updatable[:orphaned] = false
    updatable[:colour]       = params[:colour] if params.has_key? :colour
    updatable[:transparency] = params[:transparency] if params.has_key? :transparency
    updatable[:label]        = params[:label] if params.has_key? :label
    self.update_attributes updatable
  end
  
  def description_hash
    Hash[ region_name: region.name,
          region: region.description_hash,
          colour: colour,
          transparency: description,
          label: height ]
  end
  
 #def self.create_from_description perspective_id, description
 #  description = JSON.load(description) if description.kind_of? String
 #  
 #  
 #  regions = thing["regions"].map {|rdesc| Region.where("name = ?", rdesc["name"]).first or Region.create_from_description(rdesc) }.compact
 #  
 #  
 #end
  
end
