Jax.getGlobal().GeneralEventRoutingHelper = Jax.Helper.create
  camera_moved: () ->
    this.update_history()
    if @init_complete
      this.update_url()
	  
  regions_changed: () ->
    this.update_history()
    if @init_complete
      this.update_url()

  node_changed: () ->
    if @init_complete
      this.update_url()
  
  state_popped: (event) ->
    this.load_state_from_url()
