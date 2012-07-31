class Perspective < ActiveRecord::Base
  belongs_to  :style_set, :class_name => 'Perspective'
  has_many    :points_of_view, :class_name => 'Perspective', :foreign_key => 'style_set_id', :dependent => :destroy
  has_many    :own_region_styles, :class_name => 'RegionStyle', :foreign_key => 'perspective_id', :dependent => :destroy
  has_many    :regions, :through => :own_region_styles
  
  def has_external_styles?
    # does this Perspective have region_styles itself or just point to another Perspective's region_styles?
    style_set.kind_of? Perspective
  end
  
  def use_external_styles other_perspective
    other_perspective.points_of_view << self
  end
  
  def region_styles
    has_external_styles? ? style_set.region_styles : own_region_styles
  end
  
  def style_for region
    if regions.include? region
      region_styles.select { |rs| rs.region_id == region.id }.first
    else
      return false
    end
  end
  
  def disown_region_if_styled region
    if rs = style_for(region)
      rs.disown
    end
  end
  
  def update_or_create_region_style params
    if rs = style_for(params[:region])
      rs.update_attributes :colour         => params[:colour],
                           :transparency   => params[:transparency],
                           :label          => params[:label],
                           :orphaned       => false
    else
      region_styles << RegionStyle.create( :colour         => params[:colour],
                                           :transparency   => params[:transparency],
                                           :label          => params[:label],
                                           :orphaned       => false,
                                           :region_id      => params[:region].id)
    end
  end
  
end
