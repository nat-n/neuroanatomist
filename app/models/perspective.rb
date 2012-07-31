class Perspective < ActiveRecord::Base
  has_many    :region_styles, :dependent => :destroy
  has_many    :regions, :through => :region_styles
  
  def style_for region
    if regions.include? region
      region_styles.select { |rs| rs.region_id == region.id }.first
    else
      return false
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
  
  def disown_region_if_styled region
    if rs = style_for(region)
      rs.disown
    end
  end
  
end
