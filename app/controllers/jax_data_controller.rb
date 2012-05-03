class JaxDataController < ApplicationController
  
  def fetch    
    @assets = []
    #throw JSON.parse(params[:requests])
    ## find shape_set
    @shape_set = case params[:shape_set_id]
      when "default"; ShapeSet.default
      else            ShapeSet.find(request["id"]) rescue ShapeSet.default
    end
    
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

    ## prepare requested assets
    request_types = ["shape_set", "region_set", "region", "shape", "mesh"]
    required_feilds = ["type", "id"] # optional: "cascade", "included", "excluded"
    
    JSON.parse(params[:requests]).each do |request|
      if !(required_feilds-request.keys).empty?
        @assets << { :type => :error, :message => "invalid request, missing required feilds: #{required_feilds-request.keys}" }
      elsif request_types.include?(@type = request.delete("type"))
        @assets << describe_asset(request)
      else
        @assets << { :type => :error, :message => "unknown request type: #{@type}" }
      end
    end if params[:requests]
    
    render :action => "response.json"
  end
    
  private
    def describe_asset request
      new_asset = { :type => @type.to_sym }
      
      case new_asset[:type]
      when :shape_set
        new_asset[:id] = @shape_set.id
      when :region_set
        new_asset[:id] = RegionSet.find request["id"] rescue RegionSet.default
      when :region
        new_asset[:id] = Region.find request["id"] rescue return { :type => :error, :message => "Region not found with id: #{request["id"]}" }
      when :shape
        new_asset[:id] = Shape.find request["id"] rescue return { :type => :error, :message => "Shape not found with id: #{request["id"]}" }
      when :mesh
        new_asset[:id] = Mesh.find request["id"] rescue return { :type => :error, :message => "Mesh not found with id: #{request["id"]}" }
      end
      
      new_asset[:cascade] = case request["cascade"]
        when "yes";     :yes
        when "partial"; :partial
        else            :no
      end
      
      return new_asset
    end
    
end
