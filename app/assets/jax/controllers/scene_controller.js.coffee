
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    # initialise user_interface model
    # initialise scene model
    present_scene = Scene.find "primary"
    #display present_scene.region_set
    
    
    for region_def in present_scene.region_set
      new_region = Region.find "standard"
      new_region.compose_region region_def
      @world.addObject new_region
  
  
  
  display: (region_set) ->
    # region is a definition of a composite-mesh, it specifies a set of shapes to be joined.
    # a region set is constrained simply in that no two regions may share mesh primatives (this might need rethinking)
    for region_def in region_set
      new_region = Region.find "standard"
      new_region.compose_region region_def
      @world.addObject new_region
  