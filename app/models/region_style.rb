class RegionStyle < ActiveRecord::Base
  belongs_to :perspective
  belongs_to :region
  
  after_update :invalidate_caches
  
  def disown
    self.update_attributes :orphaned => true
  end
  
  def version_bump size, description, user
    perspective.version_bump size, description, user
  end
  
  def update_style params
    updatable = Hash.new
    updatable[:orphaned] = false
    updatable[:colour]       = params[:colour] if params.has_key? :colour
    updatable[:transparency] = params[:transparency] if params.has_key? :transparency
    updatable[:label]        = params[:label] if params.has_key? :label
    
    unless (!updatable.has_key? :orphaned or orphaned == updatable[:orphaned]) and 
        colour == updatable[:colour] and 
        transparency == updatable[:transparency].to_i and
        label == updatable[:label]
      version_bump (params[:size] or :minor), "RS<#{id}>", User.first 
    end
    self.update_attributes updatable
  end
  
  def description_hash
    Hash[ region_name: region.name,
          region: region.description_hash,
          colour: colour,
          transparency: transparency,
          label: label ]
  end
  
  def invalidate_caches
    perspective.invalidate_caches
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
