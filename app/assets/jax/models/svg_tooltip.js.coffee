# should expand to accomodate longer region names

gradient = (h) ->
  h = 23 if h < 23 or not h
  "270-#7d7d7d:0-#0a0a0a:"+20/h*100

Jax.getGlobal()['SVGTooltip'] = Jax.Model.create
  after_initialize: ->
    @box.style.fill = gradient(@label.h)
    @box.path = (h,w=@box.w) =>        
        h = 23 if h < 23
        r = if h > 2 * @box.r then @box.r else h/2
        return [["M",0,@box.offset.y],
                ["l",@box.offset.x,-@box.offset.y+r],
                ["c",0,-r,r,-r,r,-r],
                ["l",w-2*r,0],
                ["c",r,0,r,r,r,r],
                ["l",0,h-2*@box.r],
                ["c",0,r,-r,r,-r,r],
                ["l",2*r-w,0],
                ["c",-r,0,-r,-r,-r,-r],
                ["l",0,2*r-h],
                ["l",10,0],
                ["L",0,@box.offset.y+0.5],
                ["Z"]]
    
    @paper = Raphael(100, 100, @box.offset.x+@box.w+100, @box.h+100)
    @paper.canvas.style.opacity = 0
    $(@paper.canvas).css "pointer-events": "none"
    
    @menu.active              = false
    @menu.set                 = @paper.set()
    @menu.offset              = { x:@box.offset.x, y:@label.h+5 } 
    @menu.button.w            = @box.w
    @menu.button.offset       = { x:@box.offset.x, y:@label.h+5 }
    @menu.button.text.offset  = { x:@menu.button.offset.x+@menu.button.w/2 , y:@menu.button.offset.y+@menu.button.h/2 }    
    
    @menu.items =
      Hide: () ->
        window.context.current_controller.tooltip.paper.canvas.style["pointer-events"] = "none"
        window.context.current_controller.hide_region(window.context.current_controller.tooltip.hovered_region.id)
        window.context.current_controller.tooltip.clear()
      "Show Parts": () ->
        window.context.current_controller.decompose(window.context.current_controller.tooltip.hovered_region.id)
        window.context.current_controller.tooltip.hovered_region.decomposed = true
        window.context.current_controller.tooltip.clear()
      About: () -> 
        window.context.current_controller.sc_load_node(window.context.current_controller.tooltip.hovered_region.thing)
        window.context.current_controller.tooltip.clear()
      "Pick Colour": () ->
        window.context.current_controller.color_.show_at(730,350,window.context.current_controller.tooltip.hovered_region)
        window.context.current_controller.tooltip.clear()
    
    @box.set = @paper.set @paper.path(@box.path(@label.h)).attr(@box.style),
      @label.el = @paper.text(@box.offset.x+@box.w/2,@label.h/2,"").attr(@label.text.style)
      
    

  mouse_moved: (pageX,pageY,region) ->
    unless @menu.active
      this.hover_region(pageX,pageY,region)
  
  mouse_dragged: (pageX,pageY,region) ->
    unless @dragging
      this.clear()
    @dragging = true
  
  mouse_scrolled: (event) ->
    this.clear()
  
  mouse_released: (pageX,pageY,region) ->
    if @menu.active
      this.hide_menu(pageX,pageY,region)
    else if region
      this.show_menu(pageX,pageY,region)
  
  mouse_over_tt: (event) ->
    unless @menu.active
      this.hover_region(event.pageX, event.pageY)
  
  hover_region: (pageX,pageY,region) ->
    if region
      if @hovered_region != region
        @hovered_region = region
        this.update_label()
      @paper.canvas.style.left = ""+pageX+"px"
      @paper.canvas.style.top = ""+pageY-@box.offset.y+"px"
      @paper.canvas.style.opacity = 1
    else
      this.clear()
    @dragging = false
  
  update_label: -> 
    @label.el.attr(text: @hovered_region.name)
    @box.w = Math.max(@label.el.getBBox().width+@menu.button.offset.x,@box.minw)
    @label.el.attr x: @box.offset.x+@box.w/2
    @box.set[0].attr path: @box.path(@label.h, @box.w)
    @menu.button.w             = @box.w
    @menu.button.text.offset.x = @menu.button.offset.x+@menu.button.w/2
    

  clear: ->
    @paper.canvas.style.opacity = 0
    @menu.active = false
    @hovered_region = null
    @menu.set.remove() if @menu.set.remove?
    @box.set[0].attr 
      path: @box.path(@label.h)
      fill: gradient(@label.h)
  
  show_menu: (pageX,pageY) ->
    if @hovered_region
      @menu.active = true
      new_box_height = @label.h+10
      bg_offset   = @menu.button.offset.y - @menu.button.h
      text_offset = @menu.button.text.offset.y - @menu.button.h
      
      @menu.set = @paper.set()
      for link_text of @menu.items
        continue if link_text is "Show Parts" and (@hovered_region.decomposed or not @hovered_region.decompositions.length) or
          link_text is "About" and not @hovered_region.thing
        @menu.set.push(
          @paper.rect( @menu.button.offset.x+@menu.button.margin,
                        bg_offset+=@menu.button.h, 
                        @menu.button.w-@menu.button.margin*2, 
                        @menu.button.h ).attr(@menu.button.bg.style),
          @paper.text( @menu.button.text.offset.x, 
                       text_offset+=@menu.button.h, 
                       link_text ).attr(@menu.button.text.style)
        )
        
        new_box_height  += @menu.button.h
        
        @menu.set[@menu.set.length-2].node.style["pointer-events"] = "all"
        @menu.set[@menu.set.length-1].node.style["pointer-events"] = "none"
        
        @menu.set[@menu.set.length-2]
        .hover(
          (e) -> this.attr
              "fill":      "90:0-rgba(80,80,80,0):1-rgba(110,110,110,1)"
              "opacity":   1
          (e) -> this.attr
              "fill":      "#0a0a0a"
              "opacity":   0.001
          @menu.set[@menu.set.length-2]
          @menu.set[@menu.set.length-2]
        ).click @menu.items[link_text]
        
      @menu.set.attr "clip-rect": "0,0,"+@box.offset.x+@box.w+",0"
      
      # animate expanding the menu
      @box.set[0].animate
        path: @box.path(new_box_height)
        #fill: gradient(new_box_height)
        200
      @menu.set.forEach (elem) => elem.animate
        "clip-rect": "0,0,"+(@box.offset.x+@box.w)+","+new_box_height
        200
  
  hide_menu: (pageX,pageY,region) ->
    @menu.active = false
    if @hovered_region == region
      @box.set[0].animate
        path: @box.path(@label.h)
        #fill: gradient(@label.h)
        200
      @menu.set.animate
        "clip-rect": "0,0,"+@box.offset.x+@box.w+",0"
        200
        "linear"
        @menu.set.remove
    else
      this.clear()
    this.hover_region(pageX,pageY,region)
  