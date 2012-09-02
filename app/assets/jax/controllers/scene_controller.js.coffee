Jax.Controller.create "Scene", ApplicationController,
  index: ->
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
    @history = window.context.history ?= { log: [], back: [], forward: [], previous_url: null }
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
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
	  # load visualisation and node data via url, dom, or ajax
    this.patch_world()
    setTimeout (()=>this.start()), 250
  
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper, PerspectiveHelper, GeneralEventRoutingHelper, SupContentHelper, StatusHelper ]
  
  start: (tried_loading=false) ->
    this.show_loading_spinner($('#visualisation'), true)
    return @loader.idb.load_everything(()=>this.start(true)) unless tried_loading

    perspective_id =  $('#visualisation').data('perspectiveId')
    shape_set =  $('#visualisation').data('shapeSet')
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
    
        
  
  activate_shape_set: (shape_set) ->
    @active_shape_set = shape_set
    this.configure_camera(@s3[@active_shape_set].center_point, @s3[@active_shape_set].radius)
  
  decompose: (region_uid, fire=true) ->
    d = @world.objects[region_uid].decompositions[0]
    return false unless d
    @loader.fetch_regions @active_shape_set, d.sub_regions, (data) =>
      this.hide_region(region_uid, false) if region_uid in @scene.active_ids
      for item of data
        this.show_region @scene.new_region(@active_shape_set, data[item].id), false
      this.regions_changed() if fire
  
  show_region: (id, fire=true) ->
    return false unless id and r = @scene.activate_region(id)
    @world.addObject(r).id
    this.regions_changed() if fire
    
  hide_region: (id, fire=true) ->
    @world.removeObject @scene.deactivate_region(id)
    this.regions_changed() if fire
  
  clear_regions: (fire=true) ->
    this.hide_region(r, false) for r of @world.objects
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
    