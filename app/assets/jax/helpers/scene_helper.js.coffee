Jax.getGlobal().SceneHelper = Jax.Helper.create
  activate_shape_set: (shape_set) ->
    @active_shape_set = shape_set
    this.configure_camera(@s3[@active_shape_set].center_point, @s3[@active_shape_set].radius)
  
  decompose: (region_uid, fire=true) ->
    d = @world.objects[region_uid].decompositions[0]
    return false unless d
    @loader.fetch_regions @active_shape_set, d.sub_regions, (data) =>
      this.hide_region(region_uid, false) if region_uid in @scene.active_ids
      for item of data
        this.show_region @scene.new_region(@active_shape_set, data[item].id), false
      this.regions_changed() if fire
  
  show_region: (id, fire=true) ->
    return false unless id and r = @scene.activate_region(id)
    @world.addObject(r).id
    this.regions_changed() if fire
    
  hide_region: (id, fire=true) ->
    @world.removeObject @scene.deactivate_region(id)
    this.regions_changed() if fire
  
  clear_regions: (fire=true) ->
    this.hide_region(r, false) for r of @world.objects
    this.regions_changed() if fire
  
