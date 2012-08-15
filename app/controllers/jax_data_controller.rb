

class JaxDataController < ApplicationController
  
  def fetch    
    @assets = []
    @request_string = request.fullpath
    
    if ENV["cache_server"] and (cached_request = JaxData.where(:request_string => @request_string).first)
      redirect_to cached_request.uri
      return cached_request.increment!
    end
        
    ## find shape_set
    shape_set = false
    @shape_set = case params[:shape_set_id]
      when "default"; ShapeSet.default
      else            shape_set = true and ShapeSet.find(params[:shape_set_id]) rescue (shape_set = false or ShapeSet.default)
    end
    
    ## prepare includes array
    params[:included] = params["include"].split(",").map{|x| x.to_i} rescue []
    params[:excluded] = params["exclude"].split(",").map{|x| x.to_i} rescue []
    mesh_ids = (params[:included]+params[:excluded]).map { |id| (@shape_set.mesh_ids.include?(id.to_i) ? id.to_i : nil) }.compact
    @included = (mesh_ids.empty? ? Hash.new {|h,k| h[k]=:yes } : Hash.new {|h,k| h[k]=:no })

    if !params[:included].empty?
      @shape_set.mesh_ids.each { |mesh_id| @included[mesh_id] = :yes if mesh_ids.include?(mesh_id) }
    elsif !params[:excluded].empty?
      @shape_set.mesh_ids.each { |mesh_id| @included[mesh_id] = :yes unless mesh_ids.include?(mesh_id) }
    end

    # if there are no requests then respond with the default view or the shape_set if specified
    if !params[:requests]
      if not shape_set
        @perspective = @shape_set.default_perspective
        @cascade = encode_cascade(request["cascade"])
        render :action => "defaults.json"
        return
      end
      
      @assets << describe_shape_set(request)
      
    else ## prepare descriptions of requested assets
      request_types = ["perspective", "region", "shape", "mesh"] # to request a shape_set: exclude type & id and include cascade
      required_feilds = ["type", "id"] # optional: "cascade", "included", "excluded"
      
      JSON.parse(params[:requests]).each do |request|
        missing_required_feilds = !(required_feilds-request.keys).empty?
        if missing_required_feilds and request["cascade"]
          @assets << describe_shape_set(request)
        elsif missing_required_feilds
          @assets << describe_error("invalid request, missing required feilds: #{required_feilds-request.keys}")
        elsif request_types.include?(@type = request.delete("type"))
          @assets << describe_asset(request)
        else
          @assets << describe_error("unknown request type: #{@type}")
        end
      end
    end
    
    if ENV["cache_server"]
      create_cached_response
    else
      render :action => "response.json"
    end
  end
  
  def create_cached_response
    partial_response = Hash[included:@included]
    perspectives = []
    
    @assets.each_with_index do |asset, i|
      case asset[:type] 
      when :shape_set
        partial_response[i] = Hash[t:"ss"].merge(@shape_set.hash_partial asset[:cascade])
      when :perspective
        partial_response[i] = Hash[t:"p"].merge(asset[:object].hash_partial(@shape_set, asset[:cascade]))
        perspectives << asset[:object].id if asset[:object].id
      when :region
       partial_response[i] = Hash[ t:"r"].merge(asset[:object].hash_partial(@shape_set, asset[:cascade]))
      when :shape
        partial_response[i] = Hash[t: "s",id:asset[:object].id]
      when :mesh
       partial_response[i] = Hash[t: "m",id:asset[:object].id]
      when :error
        partial_response[i] = Hash[t:"error", message:asset[:message]]
      end
    end
    
    #render :text => JSON.dump(partial_response) # for debug
    d_key = (Digest::MD5.new << Random.rand.to_s).to_s
    cache_id = (Digest::MD5.new << @request_string).to_s
    new_cache = JaxData.create  :request_string       => @request_string,
                                :response_description => JSON.dump(partial_response),
                                :cache_id             => cache_id,
                                :destroy_key          => d_key,
                                :shape_set_id         => @shape_set.id,
                                :perspectives         => perspectives.inspect[1...-1]
    
    redirect_to "#{ENV["cache_server"]}/new/#{cache_id}"
  end
  
  def fetch_partial_response
    # if newly created (less than 30s old) jax_data record has a matching cache_id then return it's partial_description attribute
    jd = JaxData.where(:cache_id => params[:cache_id]).first
    if jd and !jd.response_description.empty? and (Time.now-jd.created_at)<=30
      render :text => jd.response_description
    else
      render :text => JSON.dump({error: "invalid cache_id"})
    end
  end
  
  def fetch_shape_set_ids
    if (ss = (ShapeSet.find(params[:shape_set_id]) rescue nil))
      render :text => JSON.dump(ss.ids_hash)
    else
      render :text => JSON.dump({error: "invalid shape_set_id"})
    end
  end
  
  private
    def describe_asset request
      new_asset = { :type => @type.to_sym }
      
      case new_asset[:type]
      #when :shape_set
      #  new_asset[:id] = @shape_set.id
      when :perspective
        new_asset[:object] = (Perspective.find request["id"] rescue @shape_set.default_perspective)
      when :region
        new_asset[:object] = Region.find request["id"] rescue return { :type => :error, :message => "Region not found with id: #{request["id"]}" }
      when :shape
        new_asset[:object] = Shape.find request["id"] rescue return { :type => :error, :message => "Shape not found with id: #{request["id"]}" }
      when :mesh
        new_asset[:object] = Mesh.find request["id"] rescue return { :type => :error, :message => "Mesh not found with id: #{request["id"]}" }
      end
      
      new_asset[:cascade] = encode_cascade request["cascade"]
      return new_asset
    end
    
    def describe_error error_string
      { :type => :error, :message => error_string }
    end
    
    def describe_shape_set request
      { :type => :shape_set, :id => @shape_set, :cascade => encode_cascade(request["cascade"]) }
    end
    
    def encode_cascade cascade
      case cascade
        when "yes";     :yes
        when "partial"; :partial
        else            :no
      end
    end
    
end
