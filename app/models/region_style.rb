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
  
end
