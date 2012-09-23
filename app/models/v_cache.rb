class VCache < ActiveRecord::Base
  validates_presence_of :request_string
  validates_uniqueness_of :request_string
  
  include S3Helper
  
  def self.mode
    case ENV["CACHE_MODE"]
    when 'local'  then :local
    when 's3'     then :s3
    end
  end
  
  def self.cache request_string, response_string, params
    new_cache = Hash[ request_string: request_string,
                      request_hash:   (Digest::MD5.new << request_string).to_s,
                      response_hash:  (Digest::MD5.new << response_string).to_s ]
    if params[:cache_type] and params[:ids]
      new_cache[:cache_type] = params[:cache_type]
      new_cache[:ids]  = [*params[:ids]].join(",")
    end
    new_cache = VCache.create new_cache
    
    case VCache.mode
    when :local
      # whitespace removal would be good at this point
      File.open(new_cache.local_path, 'w') {|f| f.write response_string }
    when :s3
      S3Helper.write_to_object "/cached_responses/#{new_cache.request_hash}", response_string
    end
    
  end
  
  def self.access request_string
    @cache = VCache.where(:request_string => request_string).first
    if !@cache
      return false
    elsif @cache.expired
      @cache.delete
      return false
    end
    
    @cache.count +=1
    @cache.save
    
    case VCache.mode
    when :local
      return (File.open(@cache.local_path, 'r') rescue @cache.expire! and nil)
    when :s3
      return S3Helper.read_from_object("/cached_responses/#{@cache.request_hash}")
    end
  end
  
  def self.expire! request_string, delete=false
    VCache.where(:request_string => request_string).each {|vc| vc.expire! delete }
  end
  
  def expire! delete=false
    
    # should ping hippocampus to check for expirations
    
    case VCache.mode
    when :local
      File.delete(local_path) rescue nil
    when :s3
      S3Helper.destroy_data("/cached_responses/#{request_hash}")
    end

    return self.delete if delete
    self.expired = true
    self.save
  end
  
  def local_path
    "#{VCache.dir}/#{request_hash}.json"
  end
  
  def self.expire_regions shape_set_id, region_ids, delete=false
    VCache.where(:cache_type => 'regions').each do |vc|
      ids = vc.ids.split(",").map(&:to_i)
      vc.expire! delete if ids.shift == shape_set_id and !(ids & [*region_ids]).empty?
    end
    ping_cache_server
  end
  
  def self.expire_perspectives perspective_ids, delete=false
    VCache.where(:cache_type => 'perspectives').each { |vc| 
      vc.expire! delete unless (vc.ids.split(",").map(&:to_i) & [*perspective_ids]).empty?
    }
    ping_cache_server
  end

  def self.expire_shape_set shape_set_id, delete=false
    VCache.where(:cache_type => 'shape_set', :ids => shape_set_id).each { |vc| vc.expire! delete }
    ping_cache_server
  end
  
  private
    def self.dir
      dir = "#{Rails.root}/cached_responses"
      Dir.mkdir(dir) unless File.exists?(dir)
      dir
    end
    
    def ping_cache_server
      HTTParty.get("http://129.215.112.173:3000/check_hashes")
    end
  
end
