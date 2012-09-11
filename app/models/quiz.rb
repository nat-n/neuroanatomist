class Quiz < ActiveRecord::Base
  
  @base_perspective = "Basic Overview" # this is a dirty hard code for now
  
  def self.accessible_regions (start_perspective=nil)
    start_perspective ||= Perspective.where(name:@base_perspective).first
    all_sub_regions = lambda do |regions|
      return [] if regions.empty?
      sub_regions = []
      regions.each { |r| sub_regions += r.decompositions.first.sub_regions if r.decompositions.first}
      sub_regions -= regions
      regions+sub_regions+all_sub_regions.call(sub_regions)
    end
    all_sub_regions.call(start_perspective.regions).uniq
  end
  
  def self.viewable_regions
    Region.where("default_perspective_id")
  end
  
end
