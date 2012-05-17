Jax.getGlobal().PickingHelper = Jax.Helper.create
  mouse_moved: (event) ->
    if @picked?
      @picked.mesh.material = "scene"
    @picked = @world.pick(event.x, event.y)
    if @picked
      @picked.mesh.material = "bright"
    if @tooltip
      @tooltip.hovering event.clientX, event.clientY, @picked
  
  mouse_clicked: (event) ->
    @picked = @world.pick(event.x, event.y)
    if @tooltip
      @tooltip.region_clicked(event.clientX,event.clientY,@picked)
  