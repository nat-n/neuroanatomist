Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    @active_regions = {}
    @active_ids = []
    @inactive_regions = {}
    @newest_region = null
    @highlighted = null
  
  highlight: (region_id) ->
    if @highlighted
      @highlighted.mesh.material = @default_material
      @highlighted = null
    if region_id and context.world.objects[region_id]
      @highlighted = context.world.objects[region_id]
      @highlighted.mesh.material = @highlight_material
      return true
    return false
  
  active: (region_id) ->
    region_id in @active_ids
    
  new_region: (shape_set_id, region_id) ->
    @newest_region = Region.find("standard").compose(shape_set_id, region_id)
    @inactive_regions[@newest_region.id] = @newest_region
    @newest_region.id
  
  add_region: (region) ->
    @inactive_regions[region._id] = region
    @newest_region = region
  
  activate_newest: ->
    this.activate_region(@newest_region.id)
    
  activate_region: (id) ->
    @active_ids.push id
    @active_regions[id] = @inactive_regions[id]
    delete @inactive_regions[id]
    return @active_regions[id]
    
  deactivate_region: (id) ->
    id_in_active_ids = (id in @active_ids)
    @active_ids.splice(id_in_active_ids,id_in_active_ids)
    @inactive_regions[id] = @active_regions[id]
    delete @active_regions[id]
    return @inactive_regions[id]
  
  newest_region: -> @newest_region
  active_regions: -> @active_regions
  inactive_regions: -> @inactive_regions
  