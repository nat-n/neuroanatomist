Jax.getGlobal().GeneralEventRoutingHelper = Jax.Helper.create
  camera_moved: () ->
    this.update_history()
	  
  regions_changed: () ->
    this.update_history()
    
    
  
