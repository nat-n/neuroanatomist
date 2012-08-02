
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip_ = SVGTooltip.find "region_dark"
    @labeler_ = SVGLabeler.find "regions_light"
    this.activate_tooltip()
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
    @loader.fetch_defaults (data, textStatus, jqXHR) =>
      params =
        shape_set: data.default_shape_set.id
        requests: [
          type:"perspective"
          id: data.default_perspective.id
          cascade:"yes" ]
      @loader.fetch params, (data, textStatus, jqXHR) =>
        for region_def in data[0].regions
          this.show_region @scene.new_region(region_def)
    
    this.patch_world()
    
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper ]
  
  
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
    
  