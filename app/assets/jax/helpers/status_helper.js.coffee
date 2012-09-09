Jax.getGlobal().StatusHelper = Jax.Helper.create
  show_loading_spinner: (target, big) ->
    return false if @spinner? and @spinner.active
    opts =
      lines: 11
      length: 5
      width: 2
      radius: 4
      corners: 1
      rotate: 0
      color: '#000'
      speed: 1.6
      trail: 70
      shadow: false
      hwaccel: true
      className: 'small_spinner'
      zIndex: 2e9
      top: '300px'
      left: '300px'
    if big
      $.extend opts,
        lines: 13
        length: 27
        width:  8
        radius: 33
        shadow: true
        className: 'big_spinner'
        top: 'auto'
        left: 'auto'
    @spinner = target.spin(opts)
    @spinner.active = true
  
  hide_loading_spinner: () ->
    @spinner.spin(false)
    @spinner.active = false
    this.intialisation_complete()

  update_mode_from_url: () ->
    @mode = window.location.href.split('#')[1]
    switch @mode
      when 'editing_node'
        $('#edit_node')[0].show_edit()
      else
        if $('.embedded_node').length
          $('#edit_node')[0].hide_edit()
        if @mode and @mode[0] == '!'
          new_title = document.title
          state_object = {type:'m'}
          new_url = window.location.href.split('#')[0]
          setTimeout (()=>window.history.replaceState state_object, new_title, new_url), 10 # dirty hack i know... but it need to be async
        @mode = null
      
  update_url: () ->
    return false if @history.back[@history.back.length-1] and @history.back[@history.back.length-1] == window.location.href
    new_title = document.title
    state_object = {type:'p'}
    cp = this.camera_position()
    new_url = ""
    new_url += "/node:" + @active_node if @active_node
    new_url += "?p="+@active_shape_set+":"+@active_perspective+":"+cp.a+":"+cp.d+":"+cp.h+":"
    new_url += r + "," for r in (@scene.active_regions[r].region_id for r of @scene.active_regions).uniq()
    new_url = new_url.slice(0,new_url.length-1)
    new_url += '#'+@mode if @mode
    window.history.pushState state_object, new_title, new_url if @url_updating
    this.change(new_url)
  
  load_state_from_url: () ->
    this.load_perspective_from_url this.get_param('p'), false
    this.sc_load_node_from_url null, false
  
  intialisation_complete: () ->
    return true if @init_complete
    @init_complete = true
    this.update_mode_from_url()
    
    # this needs to go somewhere to initialise the mouse_wheel events for zooming
    @context.canvas.addEventListener 'DOMMouseScroll', this.mouse_scrolled, false
    @context.canvas.addEventListener 'mousewheel', this.mouse_scrolled, false
    
    # initialse popstate event for use of forward/back buttons
    window.onpopstate = (e) => this.state_popped(e)
    this.update_url()
    
  undo: () ->
    return false unless @history.back.length
    @history.forward.push @history.current
    @history.current = @history.back.pop()
    this.update_buttons()
    return history.back() if @url_updating
    this.load_perspective_from_url this.get_param('p', @history.log[@history.current]), false
  
  undo_all: () ->
    return false unless @history.back.length
    @history.current = @history.back[0]
    this.load_perspective_from_url this.get_param('p', @history.log[@history.current]), false
    @history.log.push "reset"
    @history.forward = []
    @history.back = []
    this.update_buttons()

  redo: () ->
    return false unless @history.forward.length
    @history.back.push @history.current
    @history.current = @history.forward.pop()
    this.update_buttons()
    return history.forward() if @url_updating
    this.load_perspective_from_url this.get_param('p', @history.log[@history.current]), false    
    
  change: (new_url) ->
    @history.forward = []
    @history.log.push new_url
    @history.back.push @history.current if @history.current>=0
    @history.current = @history.log.length-1
    this.update_buttons()
  
  update_buttons: () ->
    $('#undo_redo button').removeAttr('disabled')
    $('#undo_button').attr('disabled', 'disabled') unless @history.back.length
    $('#redo_button').attr('disabled', 'disabled') unless @history.forward.length
    
  

