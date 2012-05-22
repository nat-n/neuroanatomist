Jax.getGlobal().CanvasEventRoutingHelper = Jax.Helper.create
  key_pressed: (event) ->
    this.depth_key(event) # camera control

  mouse_dragged: (event) ->
    this.camera_drag(event) # camera control
    if @tooltip
      @tooltip.mouse_dragged event.pageX, event.pageY, @picked
  
  mouse_moved: (event) ->
    picked = @world.pick(event.x, event.y)
    @scene.highlight(picked and picked.id)
    if @tooltip
      @tooltip.mouse_moved event.pageX, event.pageY, picked
    
  mouse_released: (event) ->
    if @tooltip
      @tooltip.mouse_released event.pageX, event.pageY, @world.pick(event.x, event.y)
