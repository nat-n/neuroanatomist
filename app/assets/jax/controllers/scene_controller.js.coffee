
Jax.Controller.create "Scene", ApplicationController,
  index: ->
    loader = AssetLoader.find "standard"
    scene = Scene.find "primary"
    
    params = 
      requests: [
        type:"region"
        id:"3"
        cascade:"yes" ]
    loader.fetch params, (data, textStatus, jqXHR) =>
      new_region = Region.find("standard")
      new_region.compose(data[0])
      @world.addObject new_region
    
    teapot = new Jax.Model
      position: [0, 0, -5]
      mesh: new Jax.Mesh.Teapot

    @world.addObject teapot
    @player.lantern = LightSource.find "headlamp"
    @world.addLightSource @player.lantern
    @player.camera.setPosition  [175.1494,87.0477,39.7259]
    
    
  helpers: -> [ UserMovementHelper ]