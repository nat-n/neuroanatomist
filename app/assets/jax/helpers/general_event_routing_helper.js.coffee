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
    unless event.state == null # this seems to detect is this event is a has link being clicked?
      this.load_state_from_url()
    this.update_mode_from_url()
  
  started_fetching_data: () ->
    @activity.new()
    this.show_loading_spinner($('#visualisation'))
  
  finished_fetching_data: (shape_set_id, stores) ->
    updated = {}
    updated[shape_set_id] = stores
    @activity.end updated, () =>
      this.hide_loading_spinner()
      @loader.idb.dump_s3 ssid,  @activity.updated[ssid] for ssid of @activity.updated
    