Jax.getGlobal()['Tooltip'] = Jax.Model.create
  after_initialize: ->
    @hovered_region = null
    @menu = null
      
    @ttdiv   = $("<div></div>").attr('id',@ttdiv).appendTo('body');   
    @ttlabel = $("<div></div>").attr('id',@ttlabel).appendTo(@ttdiv);   
    @ttinfo  = $("<div></div>").attr('id',@ttinfo).appendTo(@ttdiv);   
    @ttmenu  = $("<ol></ol>").attr('id',@ttmenu).appendTo(@ttdiv);   
    
    @menu_items =
      About: () -> alert "tell you more?" 
      Hide: () ->
        window.Jax.context.current_controller.hide_region(window.Jax.context.hovered)
        window.Jax.context.current_controller.tooltip.clear()
    
    @ttdiv.css
      "display":        "none"
      "opacity":        @tt.opacity
      "font-size":      @tt.textsize
      "color":          @tt.textcolor
      "border-radius":  @tt.radius
      "background":     @tt.bgcolor
      "min-width":      @tt.minwidth
      "max-width":      @tt.maxwidth
  	
    @ttlabel.css
      "background":     @tt.labelbg
      "border-radius":  @tt.radius
      "padding":        @tt.content_padding+","+@tt.content_padding+",0,"+@tt.content_padding
      "text-align":     "center"
      "height":         @tt.labelheight

    @ttmenu.css
      "display":          "none"
      "list-style-type":  "none"
      "margin":           0
      "padding":          @tt.content_padding
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
        mia = $("<a></a>").attr('href',"#").html(item).attr("style","padding: 5px; color: "+@tt.textcolor+";")
        mia.click @menu[item]
        $("<li></li>").attr('class',@ttmenuitem).appendTo(@ttmenu).append(mia)
      $("#"+@ttmenuitem).css(@tt.menuitemcss)
      @ttmenu.slideDown 400
      @ttlabel.animate
        "border-bottom-left-radius": "0px"
        "border-bottom-right-radius": "0px"    
    
  hide_menu: (pageX,pageY,region) ->
    if @hovered_region == region
      @ttlabel.animate
        "border-bottom-left-radius": @tt.radius
        "border-bottom-right-radius": @tt.radius
        100
      @ttmenu.slideUp 400, () => @ttmenu.empty()
    else
      this.clear()
    @menu = null
    this.hover_region(pageX,pageY,region)
  