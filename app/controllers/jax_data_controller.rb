class JaxDataController < ApplicationController
  
  def fetch    
    @assets = []
    
    ## find shape_set
    @shape_set = case params[:shape_set_id]
      when "default"; ShapeSet.default
      else            ShapeSet.find(params[:shape_set_id]) rescue ShapeSet.default
    end
    
    
    # to request the shape set, simply exclude the type and id
    
    ## prepare includes array
    params[:included] = params["included"].split(",").map{|x| x.to_i} rescue []
    params[:excluded] = params["excluded"].split(",").map{|x| x.to_i} rescue []
    mesh_ids = (params[:included]+params[:excluded]).map { |id| (@shape_set.mesh_ids.include?(id.to_i) ? id.to_i : nil) }.compact
    @included = (mesh_ids.empty? ? Hash.new {|h,k| h[k]=:yes } : Hash.new {|h,k| h[k]=:no })

    if !params[:included].empty?
      @shape_set.mesh_ids.each { |mesh_id| @included[mesh_id] = :yes if mesh_ids.include?(mesh_id) }
    elsif !params[:excluded].empty?
      @shape_set.mesh_ids.each { |mesh_id| @included[mesh_id] = :yes unless mesh_ids.include?(mesh_id) }
    end

    ## prepare descriptions of requested assets
    if params[:requests]
      request_types = ["region_set", "region", "shape", "mesh"] # to request a shape_set: exclude type & id and include cascade
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
    else
      # if there are no requests then respond with the default view
      @region_set = @shape_set.default_region_set
      @cascade = encode_cascade(request["cascade"])
      render :action => "defaults.json"
      return
    end
    
    render :action => "response.json"
  end
    
  private
    def describe_asset request
      new_asset = { :type => @type.to_sym }
      
      case new_asset[:type]
      #when :shape_set
      #  new_asset[:id] = @shape_set.id
      when :region_set
        new_asset[:id] = RegionSet.find request["id"] rescue RegionSet.default
      when :region
        new_asset[:id] = Region.find request["id"] rescue return { :type => :error, :message => "Region not found with id: #{request["id"]}" }
      when :shape
        new_asset[:id] = Shape.find request["id"] rescue return { :type => :error, :message => "Shape not found with id: #{request["id"]}" }
      when :mesh
        new_asset[:id] = Mesh.find request["id"] rescue return { :type => :error, :message => "Mesh not found with id: #{request["id"]}" }
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
