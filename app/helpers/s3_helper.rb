module S3Helper
  
  def self.setup
    AWS.config :access_key_id => ENV["AWS_ACCESS_KEY_ID"], :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
    @bucket = AWS::S3.new.buckets.create(ENV["S3_BUCKET_NAME"])
  end
  
  def self.write_to_object key, data
    setup unless @bucket
    @bucket.objects[key].write data
  end
  
  def self.read_from_object key
    setup unless @bucket
    @bucket.objects[key].read
  end
  
  def self.destroy_data key
    setup unless @bucket
    @bucket.objects[key].delete
  end

  def self.destroy_dir dir
    setup unless @bucket
    @bucket.objects.each { |obj| obj.delete if dir.size > 4 and obj.key =~ /^\/?#{dir}/ }
  end
  
end
