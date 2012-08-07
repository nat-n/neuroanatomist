Jax.getGlobal().PerspectiveHelper = Jax.Helper.create
  load_perspective: (pid, fire=true) ->
    # loads the referenced perspective from the asset store or log (determined by the id)
    if String(pid).substring(0,1) == "l" # load from log
      perspective = @history.log[parseInt(((pid)).substring(1,pid.length))].perspective
      if typeof perspective == "string"
        return this.load_perspective(perspective)
    else # load from s3
      perspective = @s3[@active_shape_set].perspectives[pid]
    this.clear_regions(fire)
    cp = this.camera_position()
    this.camera_position(
      perspective.angle or cp.a,
      perspective.height or cp.h,
      perspective.distance or cp.d
    )
    # should load from or keep UIDs if possible instead of rebuilding everything!
    for region_id in perspective.regions
      this.show_region @scene.new_region(@active_shape_set, region_id), false
  
  save_perspective: (params) ->
    # returns a description of which regions are visible and the camera position
    cp = this.camera_position()
    perspective_def = $.extend(params,
      angle: cp.a
      height: cp.h
      distance: cp.d
      shape_set: @active_shape_set
      uids: []
      regions: []
      time_stamp: Date.now())
    for uid of @world.objects
      perspective_def.uids.push uid
      perspective_def.regions.push @world.objects[uid].region_id
    console.log perspective_def
    perspective_def
  
  log_current_perspective: () ->
    # logs the current perspective and returns the id of the new log item
    new_id = @history.log.length
    @history.log.push {
      timestampe: Date.now()
      event_type: "np" # new perspective 
      perspective: this.save_perspective(
        id: "l"+new_id
        name: "l-"+new_id
        style_set: false # should really work this out from history
      )
    }
    new_id
  
  update_history: () ->
    # updates the log, adds the current state to the back stack & clears the forward stack
    console.log "updating history..."
    @history.back.push this.log_current_perspective()
    @history.forward.splice(0, @history.forward.length) if @history.forward.length
  
  load_from_log: (direction, log_i) ->
    # loads the referenced log item and logs the transition
    this.load_perspective @history.log[log_i].perspective.id, false
    @history.log.push
      timestampe: Date.now()
      event_type: direction # "b" for back or "f" for forward
      perspective: log_i
    @history.log.length-1
    
  go_back: () ->
    if @history.back.length > 1
      @history.forward.push @history.back.pop()
      this.load_from_log "b", @history.back[@history.back.length-1]
      @history.back[@history.back.length-1]
    else
      0

  go_forward: () ->
    if @history.forward.length
      @history.back.push @history.forward.pop()
      this.load_from_log "f", @history.back[@history.back.length-1]
      @history.back[@history.back.length-1]
    else
      0

    
  