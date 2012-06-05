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
    if region_id and this.active(region_id)
      @highlighted = @active_regions[region_id]
      @highlighted.mesh.material = @highlight_material
      return true
    return false
  
  active: (region_id) ->
    region_id in @active_ids
    
  new_region: (region_def) ->
    @newest_region = Region.find("standard").compose(region_def)
    @inactive_regions[region_def.id] = @newest_region
    region_def.id
  
  add_region: (region) ->
    @inactive_regions[region.id] = region
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
  