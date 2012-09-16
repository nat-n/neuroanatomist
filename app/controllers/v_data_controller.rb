class VDataController < ApplicationController
  before_filter :find_shape_set, :only => [:shape_set, :perspectives, :regions]
  
  def shape_set
    render :text => JSON.dump(@shape_set.hash_partial)
  end
  
  def perspectives
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    response = Hash.new
    Perspective.find(:all, :conditions => ["id IN (?)", ids]).
      select { |p| p.defined_for? @shape_set }.
        each { |p| response[p.id] = p.hash_partial }
    render :text => JSON.dump(response)
  end
  
  def regions
    ids = params[:ids][1..-1].split(',').map(&:to_i)
    ids.delete(0)
    if params[:full] == "t"
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, true) }.map{|m| [m[:id],m]}]
      mesh_ids = @regions.map{|id,r| r[:shapes].map{|s| s[:meshes]} }.flatten.uniq
      @meshes = Hash[Mesh.find(:all, :conditions => ["id IN (?)", mesh_ids]).map{|m| [m.id,m]}]
      render :action => :regions, :formats => [:json]
    else
      @regions = Hash[Region.find(:all, :conditions => ["id IN (?)", ids]).map { |r| r.hash_partial(@shape_set, false) }.map{|m| [m[:id],m]}]
      render :text => JSON.dump(@regions)
    end
  end
  
  private
    def find_shape_set
      @shape_set = ShapeSet.find(params[:shape_set_id])
    end
end