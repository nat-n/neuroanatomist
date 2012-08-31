class JaxData < ActiveRecord::Base
  validates_presence_of :request_string, :shape_set_id
  validates_uniqueness_of :request_string
  belongs_to :shape_set
  before_destroy :destroy_cache
  
  def uri
    check_expiration
    "#{ENV["cache_server"]}/#{cache_id}"
  end
  
  def self.local_chache_dir
    dir = "#{Rails.root}/cached_responses"
    Dir.mkdir dir unless File.exist? dir
    dir
  end

  def self.local_data_path_for cache_id
    "#{self.local_chache_dir}/#{cache_id}.json"
  end
  
  def save_locally response_string
    File.open(data_path,'w') do |f|
      f.write response_string
    end
  end
  
  def data_path
    JaxData.local_data_path_for cache_id
  end
  
  def check_expiration
    update_attribute :response_description, ""  if !response_description.empty? and 30 < Time.now-created_at
  end
  
  def increment!
    JaxData.increment_counter("count",id)
  end
  
  def access_locally
    check_expiration
    ENV["cache_server"] == "local" and (File.open("#{Rails.root}/cached_responses/#{cache_id}.json", 'r') rescue false)
  end
  
  def regions
    attributes["regions"].split(/\s*,\s*/).map(&:to_i)
  end

  def perspectives
    attributes["perspectives"].split(/\s*,\s*/).map(&:to_i)
  end
  
  def self.invalidate_caches_with params    
    [*params[:shape_set],*params[:shape_sets]].uniq.each do |ss|
      shape_set_id = ShapeSet.find(ss).id
      ([*params[:perspective],*params[:perspectives]].map do |perspective|
        JaxData.where("shape_set_id = ? AND perspectives != ?", shape_set_id, "").select {|jd| jd.perspectives.include? Perspective.find(perspective).id }
      end + 
      [*params[:region],*params[:regions]].map do |region|
        JaxData.where("shape_set_id = ?", shape_set_id).select { |jd| jd.regions.include? Region.find(region).id }
      end).flatten.uniq.each { |jd| jd.destroy }
    end
  end
  
  def destroy_cache
    if ENV["cache_server"] = "local"
      File.delete data_path rescue :whatever
    elsif ENV["cache_server"]
      HTTParty.delete "#{ENV["cache_server"]}/#{cache_id}/#{destroy_key}"
    end
  end
  
end
