Jax.getGlobal().PickingHelper = Jax.Helper.create
  mouse_moved: (event) ->
    picked = @world.pick(event.x, event.y)
    @scene.highlight(picked and picked.id)
    if @tooltip
      @tooltip.mouse_moved event.pageX, event.pageY, picked
    
  mouse_released: (event) ->
    if @tooltip
      @tooltip.mouse_released event.pageX, event.pageY, @world.pick(event.x, event.y)