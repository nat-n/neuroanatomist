
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip = SVGTooltip.find "region_dark"
    @labels = LabelRing.find "standard"
    
    @world.addObject @labels
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
    # load a region_set
    params =
      shape_set: 15
      requests: [
        type:"region_set"
        id: "3"
        cascade:"yes" ]
    @loader.fetch params, (data, textStatus, jqXHR) =>
      for region_def in data[0].regions
        this.show_region @scene.new_region(region_def)
    
    window.Jax.context = @context
    window.camera = @player.camera
    
    #this.patch_world()
    #console.log @world.pickRegionalIndices(0,0,@context.canvas.width,@context.canvas.height)
    
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper ]
  
  
  show_region: (id) ->
    @world.addObject(@scene.activate_region(id)).id
    
  hide_region: (id) ->
    @world.removeObject @scene.deactivate_region(id)
      
    
  