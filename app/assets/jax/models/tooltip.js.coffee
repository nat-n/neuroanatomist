Jax.getGlobal()['Tooltip'] = Jax.Model.create
  after_initialize: ->
    @hovered_region = null
    @menu = null
      
    @ttdiv   = $("<div></div>").attr('id',@ttdiv).appendTo('body');   
    @ttlabel = $("<div></div>").attr('id',@ttlabel).appendTo(@ttdiv);   
    @ttinfo  = $("<div></div>").attr('id',@ttinfo).appendTo(@ttdiv);   
    @ttmenu  = $("<ol></ol>").attr('id',@ttmenu).appendTo(@ttdiv);   
    
    @ttdiv.hover (e) -> window.Jax.context.current_controller.tooltip.mouse_over_tt(e)
    @menu_items =
      Hide: () ->
        window.Jax.context.current_controller.hide_region(window.Jax.context.hovered)
        window.Jax.context.current_controller.tooltip.clear()
      About: () -> alert "tell you more?" 
        
    @ttdiv.css
      "display":        "none"
      "opacity":        @tt.opacity
      "font-size":      @tt.textsize
      "color":          @tt.textcolor
      "border-radius":  @tt.radius
      "background":     @tt.bgcolor
      "width":          @tt.width
  	
    @ttlabel.css
      "background":     @tt.labelbg
      "border-radius":  @tt.radius
      "padding":        @tt.small_padding
      "text-align":     "center"
      "height":         @tt.labelheight

    @ttmenu.css
      "display":          "none"
      "list-style-type":  "none"
      "margin":           0
      "padding":          0
      "padding-bottom":   @tt.content_padding
      
  mouse_moved: (pageX,pageY,region) ->
    unless @menu 
      this.hover_region(pageX,pageY,region)
  
  mouse_dragged: (pageX,pageY,region) ->
    unless @dragging
      this.hover_region()
    @dragging = true
   
  mouse_released: (pageX,pageY,region) ->
    if @menu
      this.hide_menu(pageX,pageY,region)
    else if region
      this.show_menu(pageX,pageY,region)
  
  mouse_over_tt: (event) ->
    unless @menu
      this.hover_region(event.pageX, event.pageY)
  
  hover_region: (pageX,pageY,region) ->
    if region
      if @hovered_region != region
        @hovered_region = region
        this.update_label()
        @ttdiv.show()
      @ttdiv.offset
        left: pageX + @tt.offsetX
        top:  pageY + @tt.offsetY
    else
      this.clear()
      @hovered_region = null
    @dragging = false
  
  update_label: -> @ttlabel.html(@hovered_region.name)
  
  clear: ->
    @ttdiv.hide()
    @ttmenu.hide()
    @menu = @hovered_region = null
    @ttlabel.css
      "border-bottom-left-radius": @tt.radius
      "border-bottom-right-radius": @tt.radius
    @ttlabel.empty()
    @ttinfo.empty()
    @ttmenu.empty()
    
  show_menu: (pageX,pageY) ->
    if @hovered_region
      window.Jax.context.hovered = @hovered_region.id
      @menu = @menu_items
      for item of @menu
        $("<li></li>").attr('class',@ttmenuitem).appendTo(@ttmenu).html(item).css
          "padding":          "0.2em 0.5em"
          'outer-width':      @tt.width
          'height':           "1.3em"
        .hover (-> $(this).css
            "color":            "#333"
            "text-shadow":      "1px 2px 1px rgba(9,9,9,0.1)"
            'background-color': '#AAA'),
          (-> $(this).css
            "color":            ""
            "text-shadow":      ""
            'background-color': '')
        .click @menu[item]

      @ttmenu.children().last().css
        "border-bottom-left-radius": @tt.radius
        "border-bottom-right-radius": @tt.radius
      
      @ttmenu.slideDown 200
      @ttlabel.animate
        "border-bottom-left-radius": "0px"
        "border-bottom-right-radius": "0px"
        200
    
  hide_menu: (pageX,pageY,region) ->
    if @hovered_region == region
      @ttlabel.animate
        "border-bottom-left-radius": @tt.radius
        "border-bottom-right-radius": @tt.radius
        200
      @ttmenu.slideUp 200, () => @ttmenu.empty()
    else
      this.clear()
    @menu = null
    this.hover_region(pageX,pageY,region)
  