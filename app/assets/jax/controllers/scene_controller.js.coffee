
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    loader = AssetLoader.find "standard"
    scene = Scene.find "primary"
    
    params =
      shape_set: 14
      requests: [
        type:"region"
        id: 6
        cascade:"yes" ]
    loader.fetch params, (data, textStatus, jqXHR) =>
      new_region = Region.find("standard")
      new_region.compose(data[0])
      @world.addObject new_region
    
    teapot = Teapot.find "reference"

    @world.addObject teapot
    @player.lantern = LightSource.find "floodlight"
    @world.addLightSource @player.lantern
    
    
    #@player.sun = LightSource.find "floodlight"
    #@player.sun.torus = new Jax.Model
    #  position: [0, 5, 0]
    #  mesh: new Jax.Mesh.Torus
    #@world.addObject @player.sun.torus
    
    #console.log @player.sun.camera
    
    #@world.addLightSource @player.lantern
    #@world.addLightSource @player.sun
    
  helpers: -> [ ObjectMovementHelper ]
  
  