Jax.Controller.create "Scene", ApplicationController,
  index: ->
    @active_shape_set = false
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip_ = SVGTooltip.find "region_dark"
    @labeler_ = SVGLabeler.find "regions_light"
    this.activate_tooltip()
    @history = window.context.history ?= { log: [], back: [], forward: [], recent_regions: {} }
    @s3 = window.context.s3 ?= {}
    
    # this needs to go somewhere to initialise the mouse_wheel events for zooming
    @context.canvas.addEventListener 'DOMMouseScroll', this.mouse_scrolled, false
    @context.canvas.addEventListener 'mousewheel', this.mouse_scrolled, false
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
	  # load visualisation and node data via url, dom, or ajax
    this.show_loading_spinner($('#visualisation'), true)
    
    perspective_id =  $('#visualisation').data('perspectiveId')
    shape_set =  $('#visualisation').data('shapeSet')
    node_data = $('#sup_content').data('node')
    
    unless this.load_perspective_from_url()
      @loader.cache_shape_set(shape_set) if shape_set
      shape_set_id = try shape_set.id catch err
        null
    
      init_params = 
        shape_set: shape_set_id 
        requests: [
          type:"perspective"
          id: perspective_id
          cascade:"yes" ]
      
      unless perspective_id and shape_set_id
        @loader.fetch_defaults (data, textStatus, jqXHR) =>
          this.activate_shape_set (shape_set_id or data.default_shape_set.id)
          init_params.shape_set = (shape_set_id or data.default_shape_set.id)
          init_params.requests.id = (perspective_id or data.default_shape_set.default_perspective)
          @loader.fetch init_params, (data, textStatus, jqXHR) => 
            this.load_perspective(data[0].id, false)
            this.update_history()
            this.hide_loading_spinner()
      else
        this.activate_shape_set shape_set.id
        @loader.fetch init_params, (data, textStatus, jqXHR) =>
          this.load_perspective(data[0].id, false)
          this.update_history()
          this.hide_loading_spinner()
    
    this.sc_init_node(node_data)

        
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper, PerspectiveHelper, GeneralEventRoutingHelper, SupContentHelper, StatusHelper ]
  
  activate_shape_set: (shape_set) ->
    @active_shape_set = shape_set
    this.configure_camera(@s3[@active_shape_set].center_point, @s3[@active_shape_set].radius)
  
  
  decompose: (region_uid, fire=true) ->
    d = @world.objects[region_uid].decompositions[0]
    return false unless d
    @loader.fetch_regions @active_shape_set, d.sub_regions, (data) =>
      this.hide_region(region_uid, false)
      for item of data
        this.show_region(@scene.new_region(@active_shape_set, data[item].id), false)
    this.regions_changed() if fire
  
  show_region: (id, fire=true) ->
    @world.addObject(@scene.activate_region(id)).id
    this.regions_changed() if fire
    
  hide_region: (id, fire=true) ->
    @world.removeObject @scene.deactivate_region(id)
    #@history.recent_regions[@world.objects[id].region_id] = @world.objects[id]
    this.regions_changed() if fire
  
  clear_regions: (fire=true) ->
    this.hide_region(r, fire) for r of @world.objects
    this.regions_changed() if fire
	
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
    
  