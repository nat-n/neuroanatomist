Jax.Controller.create "Explore", ApplicationController,
  index: ->
    logger.log_event(type: 'explore_index')
    @active_shape_set = false
    @active_perspective = false
    @active_node = false
    @init_complete = false
    @mode = null
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip_ = SVGTooltip.find "region_dark"
    @labeler_ = SVGLabeler.find "regions_light"
    @color_ = Color.find "standard"
    this.activate_tooltip()
    @history = window.context.history ?= { log: [], back: [], forward: [], current: -1 }
    @s3 = window.context.s3 ?= {previous_node:null}
    @activity = (() =>
      c = 0
      updated = {}
      new: ()-> c = (c+1) or 1
      end: (new_updated, callback) ->
        setTimeout (() =>
          for ss of new_updated
            updated[ss] ?= []
            updated[ss].push os for os in new_updated[ss]
            updated[ss].uniq()
          (c-=1) or ((callback() or true) and updated = {})),
          500 # wait half a second to make sure no new activities are starting immediately
      empty: () -> c<1
      updated: () -> updated
    )()
    
    @url_updating = true
    @show_hover = true
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
	  # load visualisation and node data via url, dom, or ajax
    this.patch_world()
    
    setTimeout (()=>@loader.idb.init(()=>setTimeout((()=>this.start()), 100))), 200
  
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper, PerspectiveHelper, GeneralEventRoutingHelper, SupContentHelper, StatusHelper, SceneHelper ]
  
  start: (tried_loading=false) ->
    logger.log_event(type: 'explore_start')
    this.show_loading_spinner($('#visualisation'), true)
    
    return @loader.idb.load_everything(()=>this.start(true)) unless tried_loading
    
    @loader.check_for_updates()
    @loader.idb.load_logs()
    
    perspective_id =  $('#visualisation').data('perspectiveId')
    console.log shape_set =  $('#visualisation').data('shapeSet')
    node_data = $('#sup_content').data('node')
    
    this.sc_init_node(node_data)
    
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
          shape_set_id    = shape_set_id or data.default_shape_set.id
          perspective_id  = perspective_id or data.default_shape_set.default_perspective
          this.activate_shape_set shape_set_id
          @loader.fetch_perspective shape_set_id, perspective_id, (data, textStatus, jqXHR) => 
            this.load_perspective(perspective_id, false)
            this.hide_loading_spinner()
      else
        this.activate_shape_set shape_set_id
        @loader.fetch_perspective shape_set_id, perspective_id, (data, textStatus, jqXHR) =>
          this.load_perspective(perspective_id, false)
          this.hide_loading_spinner()
	
  activate_tooltip: () ->
    if @labeler
      @labeler.clear()
    @tooltip = @tooltip_
    @labeler = null
    logger.log_event(type: 'activate_tt')
    
  activate_labels: () ->
    @labeler = @labeler_
    @tooltip.clear()
    @tooltip = null
    @labeler.pressed = false
    @labeler.source_labels()
    @labeler.draw()
    logger.log_event(type: 'activate_labels')
    