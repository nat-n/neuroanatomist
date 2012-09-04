Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    @active_regions = {}
    @active_ids = []
    @actived_regions = {} # keeps track of regions than have been instanciated by db id
    @all_regions = {}
    @newest_region = null
    @highlighted = null
  
  highlight: (uid) ->
    if @highlighted
      @highlighted.mesh.material = @default_material
      @highlighted.mesh.color = [1,1,1,1]
      @highlighted = null
    if uid and context.world.objects[uid]
      @highlighted = context.world.objects[uid]
      @highlighted.mesh.material = @highlight_material
      return true
    return false
  
  active: (uid) ->
    uid in @active_ids
    
  new_region: (shape_set_id, region_id) ->
    # if this region has been instanciated before then return its uid from inactive regions
    return prev if prev = this.region_activated(region_id)
    @newest_region = Region.find("standard").compose(shape_set_id, region_id)
    @all_regions[@newest_region.id] = @newest_region
    @actived_regions[region_id] = @newest_region.id
    @newest_region.id
  
  region_activated: (region_id) ->
    @actived_regions[region_id] or false
    
  activate_region: (id) ->
    @active_regions[id] = @all_regions[id]
    @active_ids.push id
    @all_regions[id].decomposed = false
    return @active_regions[id]
    
  deactivate_region: (id) ->
    id_in_active_ids = (id in @active_ids)
    @active_ids.splice(id_in_active_ids,id_in_active_ids)
    delete @active_regions[id]
    return @all_regions[id]
  