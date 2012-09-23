class Perspective < ActiveRecord::Base
  belongs_to  :default_for_shape_set, :class_name => 'ShapeSet',    :foreign_key => 'default_for_shape_set_id'
  belongs_to  :style_set,             :class_name => 'Perspective'
  belongs_to  :node
  has_one     :main_region,           :class_name => 'Region',      :foreign_key => 'default_perspective_id'
  has_many    :points_of_view,        :class_name => 'Perspective', :foreign_key => 'style_set_id',   :dependent => :destroy
  has_many    :own_region_styles,     :class_name => 'RegionStyle', :foreign_key => 'perspective_id', :dependent => :destroy
  has_many    :styled_regions,        :through    => :own_region_styles, :source => :region
  has_many    :versions,              :as         => :updated, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  after_update :invalidate_caches
  
  include VersioningHelper
  
  def version_bump size, description, user
    super
    VCache.expire_perspectives self.id, false
  end
  
  def save *args
    saved = super *args
    Version.init_for self, {} if saved
    saved
  end
  
  def regions
    has_external_styles? ? style_set.regions : styled_regions
  end
  
  def defined_for? shape_set
    regions.map{|region| region.definition_for shape_set }.all?
  end
  
  def make_default_for shape_set
    shape_set.default_perspective_attr = self
  end
  
  def active_regions
    # only returns regions via styles which are included/not-orphaned
    has_external_styles? ? style_set.regions : own_region_styles.select{|rs| !rs.orphaned}.map{|rs| rs.region}
  end
  
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
  
  def own_style_for region
    if styled_regions.include? region
      own_region_styles.select { |rs| rs.region_id == region.id }.first
    else
      return false
    end
  end
  
  def disown_region_if_styled region
    if rs = own_style_for(region)
      rs.disown
    end
  end
  
  def include_regions new_regions
    [*new_regions].each { |nr| update_or_create_region_style :region => nr }
  end
  
  def update_or_create_region_style params
    if rs = style_for(params[:region])
      params.select! { |k,_| [:colour,:transparency,:label].include? k }
      params[:orphaned] = false
      rs.update_style params
    else
      region_styles << RegionStyle.create( :colour         => params[:colour],
                                           :transparency   => params[:transparency],
                                           :label          => params[:label],
                                           :orphaned       => false,
                                           :region_id      => params[:region].id)
    end
  end
  
  def hash_partial
    Hash[
      id:         self.id,
      version:    self.version.to_s,
      name:       self.name,
      style_set:  (self.has_external_styles? ? self.style_set.id : false),
      height:     self.height,
      angle:      self.angle,
      distance:   self.distance,
      regions:    self.active_regions.map(&:id)
    ]
  end
  
  def description_hash
    h = Hash[ id:           id,
              name:         name,
              version:      version.to_s,
              description:  description,
              height:       height,
              angle:        angle,
              distance:     distance]
    if has_external_styles?
      h[:style_set] = style_set 
    else
      h[:regions] = []
      own_region_styles.each do |rs|
        h[:regions] << rs.description_hash
      end
    end
    return h
  end
  
  
  def self.create_from_description description
    throw description = JSON.load(description) if description.kind_of? String
    
    new_perspective = Perspective.create  name: description["name"],
                                          description: description["description"],
                                          height: description["height"],
                                          angle: description["angle"],
                                          distance: description["distance"]
    if description.has_key? "style_set"
      new_perspective.style_set = description["style_set"]
    else
      description["regions"].each do |rsdesc|
        region = (Region.where("name = ?", rsdesc["region_name"]).first or Region.create_from_description(rsdesc["region"]))
        update_or_create_region_style region: region,
                                      colour: rsdesc["colour"],
                                      transparency: rsdesc["transparency"],
                                      label: rsdesc["label"]
      end
    end
  end
  
  def invalidate_caches
    VCache.expire_perspectives self.id, false
  end
  
end
