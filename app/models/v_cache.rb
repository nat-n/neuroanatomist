class VCache < ActiveRecord::Base
  validates_presence_of :request_string
  validates_uniqueness_of :request_string
  
  
  def self.mode
    case ENV["CACHE_SERVER"]
    when 'local'  then :local
    when nil      then :local
    when 's3'     then :s3
    end
  end
  
  def self.cache request_string, response_string, params
    new_cache = Hash[ request_string: request_string,
                      cache_id:       (Digest::MD5.new << request_string).to_s ]
    new_cache[:destroy_key] = params[:destroy_key].to_s if params[:destroy_key]
    if params[:type] and params[:ids]
      new_cache[:type] = params[:type]
      new_cache[:ids]  = [*params[:ids]].join(",")
    end
    new_cache = VCache.create new_cache
    
    case VCache.mode
    when :local
      # whitespace removal would be good at this point
      File.open(new_cache.local_path, 'w') {|f| f.write response_string }
    when :s3
      
    end
    
  end
  
  def self.access request_string
    @cache = VCache.where(:request_string => request_string).first
    return false unless @cache and not @cache.expired
    
    @cache.count +=1
    @cache.save
    
    case VCache.mode
    when :local
      return (File.open(@cache.local_path, 'r') rescue @cache.destroy and nil)
    when :s3
      
    end
  end
  
  def self.expire request_string, delete=false
    @cache = VCache.where(:request_string => request_string).first
    # if remote cache also then send it the destroy key
    
    case VCache.mode
    when :local
      File.delete(@cache.local_path)
    when :s3
      
    end
    
    if delete
      @cache.delete
    else
      expired = true
      save
    end
  end

  def local_path
    "#{VCache.dir}/#{cache_id}.json"
  end
  
  private
    def self.dir
      dir = "#{Rails.root}/cached_responses"
      Dir.mkdir(dir) unless File.exists?(dir)
      dir
    end
      
  
end
