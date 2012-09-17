class VDataController < ApplicationController
  before_filter :find_shape_set, :only => [:shape_set, :perspectives, :regions]
  before_filter :check_cache, :only => [:shape_set, :perspectives, :regions]
  
  def shape_set
    render_and_cache JSON.dump(@shape_set.hash_partial)
  end
  
  def perspectives
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    response = Hash.new
    Perspective.find(:all, :conditions => ["id IN (?)", ids]).
      select { |p| p.defined_for? @shape_set }.
        each { |p| response[p.id] = p.hash_partial }
    render_and_cache JSON.dump(response)
  end
  
  def regions
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    if params[:full] == "t" or params[:full] == "true"
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, true) }.map{|m| [m[:id],m]}]
      mesh_ids = @regions.map{|id,r| r[:shapes].map{ |s| s[:meshes]} }.flatten.uniq
      @meshes = Hash[Mesh.find(:all, :conditions => ["id IN (?)", mesh_ids]).map{|m| [m.id,m]}]
      if params[:excl]
        exclude = params[:excl].split(',').map(&:to_i)
        @meshes.reject! { |id,m| exclude.include? id }
      end
      render_and_cache render_to_string(:action => :regions, :formats => [:json])
    else
      @destroy_key = (params.has_key?(:dk) ? (Digest::MD5.new << Random.rand.to_s).to_s : nil)
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, false) }.map{|m| [m[:id],m]}]
      @regions.merge! :destroy_key => (Digest::MD5.new << @destroy_key).to_s if @destroy_key
      render_and_cache JSON.dump(@regions)
    end
  end
  
  private
  
    def find_shape_set
      @shape_set = ShapeSet.find(params[:shape_set_id])
    end
    
    def render_and_cache response_string
      render :text => response_string
      VCache.cache "#{request.path}?#{request.query_string}", response_string, :destroy_key => @destroy_key
    end
    
    def check_cache
      cached_version = VCache.access "#{request.path}?#{request.query_string}"
      if cached_version
        cached_version = cached_version.read if cached_version.is_a? File
        render :text => cached_version
        return false
      end
    end
end