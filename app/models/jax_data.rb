class JaxData < ActiveRecord::Base
  validates_presence_of :request_string, :shape_set_id
  validates_uniqueness_of :request_string
  belongs_to :shape_set
  before_destroy :destroy_cache
  
  def uri
    check_expiration
    "#{ENV["cache_server"]}/#{cache_id}"
  end
  
  def check_expiration
    update_attribute :response_description, ""  if !response_description.empty? and 30 < Time.now-created_at
  end
  
  def increment!
    JaxData.increment_counter("count",id)
  end
  
  def destroy_cache
    HTTParty.delete "#{ENV["cache_server"]}/#{cache_id}/#{destroy_key}"
  end
  
end
