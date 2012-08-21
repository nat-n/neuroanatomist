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
  
  def destroy_cache
    if ENV["cache_server"] = "local"
      File.delete data_path
    elsif ENV["cache_server"]
      HTTParty.delete "#{ENV["cache_server"]}/#{cache_id}/#{destroy_key}"
    end
  end
  
end
