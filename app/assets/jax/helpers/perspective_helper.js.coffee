Jax.getGlobal().PerspectiveHelper = Jax.Helper.create
  load_perspective_from_url: (url_param, fire=true) ->
    # url scheme: p=shape_set_id:perspective_id:angle:distance:height:r1,r2,r3...
    return false unless url_param or (url_param = this.get_param('p'))
    ss = url_param.split(':')[0]
    # need to have the shape_set first!!!
    if ss of @s3
      this.activate_shape_set ss unless @active_shape_set == ss
      if (perspective = this.validate_perspective(url_param))
        this.load_perspective @loader.cache_perspective(perspective, @active_shape_set), fire
      else
        return false
    else
      return false unless (perspective = this.validate_perspective(url_param))
      @loader.fetch_shape_set ss, () =>
        this.activate_shape_set ss unless @active_shape_set == ss
        this.load_perspective @loader.cache_perspective(perspective, @active_shape_set), fire
    return true # should indicate success!
  
  validate_perspective: (url_param) ->
    components = url_param.split(':')
    perspective = {id:components[1],regions:[],name:"url_persepective"}
    return false unless components.length == 6 and 
      (perspective.angle = parseFloat(components[2])) != NaN and
      (perspective.distance = parseFloat(components[3])) != NaN and
      (perspective.height = parseFloat(components[4])) != NaN

    for r in components[5].split(',')
      return false unless parseInt(r)
      perspective.regions.push parseInt(r)
    perspective.regions = perspective.regions.uniq()
    return perspective
  
  load_perspective: (pid, fire=true, whitewash=false) ->
    # loads the referenced perspective from the asset store or log (determined by the id)
    # requires @active_shape_set to be set correctly
    #if String(pid).substring(0,1) == "l" # load from log
    #  console.log parseInt(pid.substring(1,pid.length))s3
    #  
    #  perspective = @history.log[parseInt(pid.substring(1,pid.length))].perspective
    #  return this.load_perspective(perspective) if typeof perspective == "string"
    #else 
    perspective = @s3[@active_shape_set].perspectives[pid] # load from s3
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
    
    if whitewash then color = [1,1,1,1]
    else color = null
    
    if missing_regions.length
      @loader.fetch_regions @active_shape_set, missing_regions, (data) =>
        for region_id in perspective.regions                    #### !!! not sure what'll happen in jaxdata if fake region requested ???
          if region_id of @s3[@active_shape_set].regions
            this.show_region @scene.new_region(@active_shape_set, region_id, color), false
          else
            console.log "ERROR: No such region with id "+region_id
        this.regions_changed() if fire
        this.hide_loading_spinner()
        @active_perspective = pid
    else
      for region_id in perspective.regions
          this.show_region @scene.new_region(@active_shape_set, region_id, color), false
      this.regions_changed() if fire
      this.hide_loading_spinner()
      @active_perspective = pid
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
    