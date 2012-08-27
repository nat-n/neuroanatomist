Jax.getGlobal().PerspectiveHelper = Jax.Helper.create
  load_perspective_from_url: () ->
    # url scheme: p=shape_set_id:perspective_id:angle:distance:height:r1,r2,r3...
    return false unless url_param = this.get_param('p')
    ss = url_param.split(':')[0]
    # need to have the shape_set first!!!
    if ss of @s3
      @active_shape_set = ss
      if (perspective = this.validate_perspective(url_param))
        this.load_perspective @loader.cache_perspective(perspective, @active_shape_set)
      else
        return false
    else
      return false unless (perspective = this.validate_perspective(url_param))
      @loader.fetch_shape_set ss, () =>
        @active_shape_set = ss
        this.load_perspective @loader.cache_perspective(perspective, @active_shape_set)
    return true # should indicate success!
  
  validate_perspective: (url_param) ->
    components = url_param.split(':')
    perspective = {id:components[1],regions:[],name:"url_persepective"}
    return false unless components.length == 6 and 
      (perspective.angle = parseInt(components[2])) != NaN and
      (perspective.distance = parseInt(components[3])) != NaN and
      (perspective.height = parseInt(components[4])) != NaN
    return false unless (perspective.regions.push(parseInt(r)) and parseInt(r)) != NaN for r in components[5].split(',')
    return perspective
  
  load_perspective: (pid, fire=true) ->
    # loads the referenced perspective from the asset store or log (determined by the id)
    # requires @active_shape_set to be set correctly
    if String(pid).substring(0,1) == "l" # load from log
      perspective = @history.log[parseInt(pid.substring(1,pid.length))].perspective
      return this.load_perspective(perspective) if typeof perspective == "string"
    else perspective = @s3[@active_shape_set].perspectives[pid] # load from s3
    this.clear_regions(false)
    cp = this.camera_position()
    this.camera_position perspective.angle or cp.a,
                         perspective.height or cp.h,
                         perspective.distance or cp.d
    # should load from or keep UIDs if possible instead of rebuilding everything!
    # but need to first fetch any regions that we don't have
    missing_regions = []
    for region_id in perspective.regions
      missing_regions.push region_id unless region_id of @s3[@active_shape_set].regions
    
    if missing_regions.length
      @loader.fetch_regions @active_shape_set, missing_regions, (data) =>
        for region_id in perspective.regions                    #### !!! not sure what'll happen in jaxdata if fake region requested ???
          if region_id of @s3[@active_shape_set].regions
            this.show_region @scene.new_region(@active_shape_set, region_id), false
          else
            console.log "ERROR: No such region with id "+region_id
    else
      for region_id in perspective.regions
          this.show_region @scene.new_region(@active_shape_set, region_id), false
    this.regions_changed() if fire
    this.hide_loading_spinner()
    true # should indicate success...
  
  save_perspective: (params) ->
    # returns a description of which regions are visible and the camera position
    cp = this.camera_position()
    perspective_def = $.extend params,
      angle: cp.a
      height: cp.h
      distance: cp.d
      shape_set: @active_shape_set
      regions: []
      time_stamp: Date.now()
    for uid of @world.objects
      perspective_def.regions.push @world.objects[uid].region_id
    perspective_def
  
  log_current_perspective: () ->
    # logs the current perspective and returns the id of the new log item
    new_id = @history.log.length
    @history.log.push
      timestampe: Date.now()
      event_type: "np" # new perspective 
      perspective: this.save_perspective
        id: "l"+new_id
        name: "l-"+new_id
        style_set: false # should really work this out from history
    new_id
  
  update_history: () ->
    # updates the log, adds the current state to the back stack & clears the forward stack
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
    @tooltip.clear()
    if @history.back.length > 1
      @history.forward.push @history.back.pop()
      this.load_from_log "b", @history.back[@history.back.length-1]
      @history.back[@history.back.length-1]
    else false

  go_forward: () ->
    @tooltip.clear()
    if @history.forward.length
      @history.back.push @history.forward.pop()
      this.load_from_log "f", @history.back[@history.back.length-1]
      @history.back[@history.back.length-1]
    else false

    
  