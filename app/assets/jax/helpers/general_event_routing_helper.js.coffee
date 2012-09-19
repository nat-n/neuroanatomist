Jax.getGlobal().GeneralEventRoutingHelper = Jax.Helper.create
  camera_moved: () ->
    logger.log_event(type: 'camera_moved')
    if @init_complete
      this.update_url()
	  
  regions_changed: () ->
    logger.log_event(type: 'regions_changed')
    if @init_complete
      this.update_url()

  node_changed: () ->
    logger.log_event(type: 'node_changed')
    if @init_complete
      this.update_url()
  
  state_popped: (event) ->
    unless event.state == null # this seems to detect is this event is a has link being clicked?
      logger.log_event(type: 'state_popped')
      this.load_state_from_url()
    this.update_mode_from_url()
  
  started_fetching_data: () ->
    @activity.new()
    this.show_loading_spinner($('#visualisation'))
    logger.log_event(type: 'started_fetching_data')
  
  finished_fetching_data: (shape_set_id, stores) ->
    updated = {}
    updated[shape_set_id] = stores
    @activity.end updated, () =>
      this.hide_loading_spinner()
      for ssid of @activity.updated()
        @loader.idb.dump_s3 ssid,  @activity.updated()[ssid] 
      logger.log_event(type: 'finished_fetching_data')
    