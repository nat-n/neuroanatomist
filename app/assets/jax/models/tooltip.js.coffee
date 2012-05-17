# user should need to click off a menu to deactivate it once activated !!

Jax.getGlobal()['Tooltip'] = Jax.Model.create
  after_initialize: ->
    # find or create tooltip, ttlabal, ttinfo and ttmenu
    @hovered_region = null
    @menu_visible = false
    
    @tt = 
      offsetX: 20
      offsetY: -35
      width: 130
      radius: "14px"
      opacity: 0.85
      textsize: "0.95em"
      textcolor: "#fffeff"
      labelbg: "url(/assets/ttgradient.png) repeat-x"
      labelheight: "1.5em"
      bgcolor: "#0a0a0a"
      content_padding: "0.15em"
      menuitemcss: ""
      menu_items:
        "About": ()-> alert "tell you more?"
        "Hide": () -> alert "you can't see me!"
      
    @ttdiv   = $("<div></div>").attr('id',@ttdiv).appendTo('body');   
    @ttlabel = $("<div></div>").attr('id',@ttlabel).appendTo(@ttdiv);   
    @ttinfo  = $("<div></div>").attr('id',@ttinfo).appendTo(@ttdiv);   
    @ttmenu  = $("<ol></ol>").attr('id',@ttmenu).appendTo(@ttdiv);   
    @ttdiv.hide()
    @ttmenu.hide()
    @ttdiv.css("opacity", @tt.opacity)
    @ttdiv.css("font-size", @tt.textsize)
    @ttdiv.css("color", @tt.textcolor)
  	
    @ttdiv.css("border-radius", @tt.radius)
    @ttdiv.css("background",    @tt.bgcolor)
    @ttdiv.css("padding-bottom", @tt.content_padding)
    @ttdiv.width(@tt.width)   
  	
    @ttlabel.css("background", @tt.labelbg)
    @ttlabel.css("border-radius", @tt.radius)
    @ttlabel.css("padding", @tt.content_padding)
    @ttlabel.css("text-align", "center")
    @ttlabel.height(@tt.labelheight)
    @ttmenu.css("padding", @tt.content_padding)
    @ttmenu.css("margin", 0)
    @ttmenu.css("list-style-type", "none")
    
  hovering: (pageX,pageY,region) ->
    unless @menu_visible
      if @hovered_region == region
        this.update_position(pageX,pageY)
      else if region
        @hovered_region = region
        this.update_label()
        this.update_position(pageX,pageY)
      else
        @hovered_region = null
        this.clear_tooltip()
  
  region_clicked: (pageX, pageY, region) ->
    if @menu_visible
      this.hide_menu(pageX,pageY,region)
    else if region
      this.hovering(pageX, pageY, region)
      this.show_menu(pageX,pageY,region)
      
  dragged: () ->
    this.hovering(event.clientX,event.clientY)
  
  update_position: (pageX,pageY) ->
    @ttdiv.offset({left:pageX+@tt.offsetX,top:pageY+@tt.offsetY});
    @ttdiv.show()

  clear_tooltip: () ->
    @ttdiv.hide()
    @ttlabel.html("")
    @ttinfo.html("")
    @ttmenu.html("")
    
  update_label: ->
    @ttlabel.html(@hovered_region.name)    
  
  show_menu: (pageX,pageY,region) ->
    @menu_visible = true
    this.update_position(pageX,pageY)
    for item of @tt.menu_items
      mia = $("<a></a>").attr('href',"#").html(item).attr("style","padding: 5px; color: "+@tt.textcolor+";")
      mia.click () => @tt.menu_items[item]()
      $("<li></li>").attr('class',@ttmenuitem).appendTo(@ttmenu).append(mia)
    $("#"+@ttmenuitem).css(@tt.menuitemcss)
    @ttmenu.slideDown 400
    @ttlabel.animate({"border-bottom-left-radius": "0px"; "border-bottom-right-radius": "0px";})
    
      
  hide_menu: (pageX,pageY, region) ->
    this.clear_tooltip() unless region
    @menu_visible = false
    @ttlabel.animate {"border-bottom-left-radius": @tt.radius; "border-bottom-right-radius": @tt.radius;}, 'fast'
    @ttmenu.slideUp 400, ()=> @ttmenu.html("")
    this.update_position(pageX,pageY)
    