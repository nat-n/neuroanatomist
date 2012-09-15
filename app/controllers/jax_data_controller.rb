class JaxDataController < ApplicationController
  
  def fetch
    @assets = []
    @request_string = request.fullpath
    
    
    if ENV["CACHE_SERVER"] and (cached_request = JaxData.where(:request_string => @request_string).first)
      if (local_file = cached_request.access_locally)
        return render :file => local_file.path#, :content_type => Mime::Type.lookup_by_extension(:json).to_s
      elsif ENV["CACHE_SERVER"] != "local"
        redirect_to cached_request.remote_uri
        return
      else
        cached_request.destroy
      end
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
        if params['cascade']
          params['cascade'].downcase!
        else
          params['cascade'] = 'no'
        end
        shape_set_hash = @shape_set.hash_partial(['1','true'].include? params['cascade'].downcase)
        render :text => JSON.dump(Hash["default_shape_set" => shape_set_hash.merge(shape_set_hash.delete(:attrs))])
        return
      end
      @assets << describe_shape_set(request)
      
    else ## prepare descriptions of requested assets
      request_types = ["perspective", "region", "shape", "mesh"] # to request a shape_set: exclude type & id and include cascade
      required_feilds = ["type", "id"] # optional: "cascade", "included", "excluded"
      
      [*JSON.parse(params[:requests])].each do |req|
        # copy request with full versions of abbreviated keys and values
        request = Hash.new
        req.each do |k,v|
          key = case k
          when "t"; "type"
          when "c"; "cascade"
          else; k
          end
          val = case v
          when "ss"; "shape_set"
          when "p"; "perspective"
          when "r"; "region"
          else; v
          end
          request[key] = val
        end
        
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
    
    response = describe_response
    
    if ENV["CACHE_SERVER"] and ENV["CACHE_SERVER"] != "local"
      redirect_to "#{ENV["CACHE_SERVER"]}/#{response.cache_id}/#{response.destroy_key}"
    else
      
      @assets = JSON.load response.response_description
      @assets.delete "included"
      @assets.delete "shape_set"
      @shapes = Hash[Shape.where(:shape_set_id => @shape_set.id).map { |s| [s.id, s] }]
      @meshes = Hash[Mesh.where(:shape_set_id => @shape_set.id).map { |m| [m.id, m] }]
      
      if ENV["CACHE_SERVER"] = "local"
        cache_path = JaxData.local_data_path_for response.cache_id
        response_string = render_to_string(:action => "response.json", :layout => false)
        response.save_locally response_string
        render :file => cache_path
        return true
      end

      render :action => "response.json"
    end
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
  
  def update
    
    render :text => JSON.dump({error: "invalid shape_set_id"}) unless @shape_set = ShapeSet.find(params[:shape_set_id])
    
    render :text => JSON.dump(@shape_set.latest)
    
  end
  
  private
  
    def describe_response
      partial_response = Hash[
        included:@included,
        shape_set: {id: @shape_set.id, subject: @shape_set.subject, version: @shape_set.version.to_s }
      ]
      perspectives = []
      regions = []

      @assets.each_with_index do |asset, i|
        case asset[:type] 
        when :shape_set
          partial_response[i] = Hash[t:"ss", cascade:asset[:cascade]].merge(@shape_set.hash_partial asset[:cascade])
        when :perspective
          partial_response[i] = Hash[t:"p", cascade:asset[:cascade]].merge(asset[:object].hash_partial(@shape_set, asset[:cascade]))
          perspectives << asset[:object].id if asset[:object].id
          if asset[:cascade] and asset[:cascade] != :no
            regions += partial_response[i][:regions].map{|r| r[:attrs][:id]} if partial_response[i][:regions]
          else
            partial_response[i][:attrs][:regions] = partial_response[i].delete(:regions)
          end
        when :region
         partial_response[i] = Hash[ t:"r", cascade:asset[:cascade]].merge(asset[:object].hash_partial(@shape_set, asset[:cascade]))
         regions << asset[:object].id if asset[:object].id
        when :shape
          partial_response[i] = Hash[t: "s", cascade:asset[:cascade],id:asset[:object].id]
        when :mesh
         partial_response[i] = Hash[t: "m", cascade:asset[:cascade],id:asset[:object].id]
        when :error
          partial_response[i] = Hash[t:"error", message:asset[:message]]
        end
      end

      JaxData.create  :request_string       => @request_string,
                      :response_description => JSON.dump(partial_response),
                      :cache_id             => (Digest::MD5.new << @request_string).to_s,
                      :destroy_key          => (Digest::MD5.new << Random.rand.to_s).to_s,
                      :shape_set_id         => @shape_set.id,
                      :perspectives         => perspectives.inspect[1...-1],
                      :regions              => regions.inspect[1...-1]
    end
    
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
      { :type => :shape_set, :id => @shape_set, :cascade => encode_cascade((request["cascade"] or params["cascade"])) }
    end
    
    def encode_cascade cascade
      case cascade
        when "yes";     :yes
        when "partial"; :partial
        else            :no
      end
    end
    
end
