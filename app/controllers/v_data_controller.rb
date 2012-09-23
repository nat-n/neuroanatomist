class VDataController < ApplicationController
  before_filter :find_shape_set, :only => [:shape_set, :perspectives, :regions]
  before_filter :check_cache, :only => [:shape_set, :perspectives, :regions]
  
  def defaults
    render :text => JSON.dump(Hash[default_shape_set: ShapeSet.default.hash_partial])
  end
  
  def shape_set
    cache_params = Hash[
      cache_type:   "shape_set",
      ids:          [@shape_set.id]
      ]
    render_and_cache JSON.dump(@shape_set.hash_partial), cache_params
  end
  
  def perspectives
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    response = Hash.new
    perspectives = Perspective.find(:all, :conditions => ["id IN (?)", ids]).select { |p| p.defined_for? @shape_set }
    perspectives.each { |p| response[p.id] = p.hash_partial }
    
    cache_params = Hash[
      cache_type:   "perspectives",
      ids:          [@shape_set.id]+[*perspectives.map(&:id)]
      ]
    
    render_and_cache JSON.dump(response), cache_params
  end
  
  def regions
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    
    cache_params = Hash[
      cache_type:   "regions",
      ids:          [@shape_set.id]
      ]
    
    if params[:full] == "t" or params[:full] == "true"
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, true) }.map{|m| [m[:id],m]}]
      mesh_ids = @regions.map{|id,r| r[:shapes].map{ |s| s[:meshes]} }.flatten.uniq
      @meshes = Hash[Mesh.find(:all, :conditions => ["id IN (?)", mesh_ids]).map{|m| [m.id,m]}]
      
      if params[:excl]
        exclude = params[:excl].split(',').map(&:to_i)
        @meshes.reject! { |id,m| exclude.include? id }
      end

      cache_params[:ids] += @regions.keys

      render_and_cache render_to_string(:action => :regions, :formats => [:json]), cache_params
    
    else
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, false) }.map{|m| [m[:id],m]}]
      cache_params[:ids] += @regions.keys
      
      render_and_cache JSON.dump(@regions), cache_params
    end
  end
  
  def check_hashes
    render :text => JSON.dump(Hash[ VCache.all.map { |vc| [vc.request_hash,vc.response_hash] } ])
  end
  
  def shape_set_ids
    ss = ShapeSet.where(:subject => params[:subject]).select {|ss| ss.version.major.to_s == params[:major_version] }.first
    if ss
      render :text => JSON.dump(ss.ids_hash)
    else
      render :text => JSON.dump({error: "invalid shape_set_id"})
    end
  end
  
  def updates
    render :text => JSON.dump(ShapeSet.find(params[:shape_set_id]).latest)
  end
  
  private
  
    def find_shape_set
      @shape_set = ShapeSet.find(params[:shape_set_id])
    end
    
    def render_and_cache response_string, cache_params
      render :text => response_string
      VCache.cache "#{request.path}?#{request.query_string}", response_string, cache_params
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