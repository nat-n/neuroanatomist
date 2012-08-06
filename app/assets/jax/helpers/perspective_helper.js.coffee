Jax.getGlobal().PerspectiveHelper = Jax.Helper.create
  load_perspective: (perspective_id) ->
    # loads the referenced perspective from the asset store
    this.clear_regions()
    perspective = window.context.s3[@active_shape_set].perspectives[perspective_id]
    cp = this.camera_position()
    this.camera_position(
      perspective.angle or cp.a,
      perspective.height or cp.h,
      perspective.distance or cp.d
    )
    for region_id in perspective.regions
      this.show_region @scene.new_region(@active_shape_set, region_id)
  
  save_perspective: () ->
    # saves a description of which regions are visible and the camera position
    # maybe should save jax id as well as 
    cp = this.camera_position()
    perspective_def =
      angle: cp.a
      height: cp.h
      distance: cp.d
      id: "h1" # acts as an index within the history buffer, along with the timestamp
      name: "saved-null"
      style_set: false # should work this out from history
      uids: []
      regions: []
    for uid of @world.objects
      perspective_def.uids.push uid
      perspective_def.regions.push @world.objects[uid].region_id
    perspective_def
