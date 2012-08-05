
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    @active_shape_set = false
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip_ = SVGTooltip.find "region_dark"
    @labeler_ = SVGLabeler.find "regions_light"
    this.activate_tooltip()
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
	# fetch default visualisation data
    @loader.fetch_defaults (data, textStatus, jqXHR) =>
      this.activate_shape_set(data.default_shape_set.id)
      params =
        shape_set: data.default_shape_set.id
        requests: [
          type:"perspective"
          id: data.default_perspective.id
          cascade:"yes" ]
      @loader.fetch params, (data, textStatus, jqXHR) => this.load_perspective(data[0].id)
    
    this.patch_world()
    
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper ]
  
  activate_shape_set: (shape_set) ->
    @active_shape_set = shape_set
    this.configure_camera(window.JAS[@active_shape_set].center_point, window.JAS[@active_shape_set].radius)
  
  load_perspective: (perspective_id) ->
    # loads the referenced perspective from the asset store
    perspective = window.JAS[@active_shape_set].perspectives[perspective_id]
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
  
  decompose: (region_uid) ->
    d = @world.objects[region_uid].decompositions[0]
    return false unless d
    @loader.fetch_regions @active_shape_set, d.sub_regions, (data) =>
      this.hide_region (region_uid)
      for item of data
        this.show_region @scene.new_region(@active_shape_set, data[item].id)
  
  show_region: (id) ->
    @world.addObject(@scene.activate_region(id)).id
    
  hide_region: (id) ->
    @world.removeObject @scene.deactivate_region(id)
  
  activate_tooltip: () ->
    if @labeler
      @labeler.clear()
    @tooltip = @tooltip_
    @labeler = null
    
  activate_labels: () ->
    @labeler = @labeler_
    @tooltip.clear()
    @tooltip = null
    @labeler.pressed = false
    @labeler.source_labels()
    @labeler.draw()
    
  