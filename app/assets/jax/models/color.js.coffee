Jax.getGlobal()['Color'] = Jax.Model.create
  after_initialize: ->
    @hues = [0, 0.04, 0.08, 0.1111, 0.1481, 0.1851, 0.2222, 0.2592, 0.33, 0.42, 0.48, 0.5185, 0.5556, 0.5926, 0.6297, 0.6667, 0.72, 0.75, 0.78, 0.82, 0.8519, 0.9, 0.94]
    @shades = [ # saturation and brightness
          0.7, 0.45,
          0.55, 0.45,
          1, 0.725,
          0.7, 0.725,
          0.55, 0.725,
          1, 1,
          0.8, 1,
          0.65, 1,
          0.45, 1
    ]
    @rows = @shades.length/2
    @cols = @hues.length
    @width = 25
    @spacing = 0 
    @border = 8
    @shuffle = false
    @colours = []
    for h in @hues
      for s in [0...@shades.length/2]
        @colours.push Raphael.color
          h: h
          s: @shades[s*2]
          b: @shades[s*2+1]
        
    @colours.sort(() -> 0.5 - Math.random()) if @shuffle
    
    @paper = Raphael 0, 0, 2*@border+@cols*@width+@cols*@spacing, 2*@border+@rows*@width+@rows*@spacing
    this.hide()
  
  
  show_at: (pageX, pageY, target_region) ->
    @target_region = target_region
    @paper.canvas.style.left = ""+pageX+"px"
    @paper.canvas.style.top = ""+pageY+"px"
    @paper.canvas.style.opacity = 1
    @paper.rect(0, 0, @paper.width, @paper.height).attr(fill: 'white')
    .click (e) -> context.current_controller.color_.target_region.mesh.setColor [1,1,1,1]
    r=0
    c=0
    for fill in @colours
      if r == @rows
        c +=1
        r = 0
      @paper.rect @border+c*@width+c*@spacing,
                  @border+r*@width+r*@spacing,
                  @width,
                  @width
      .attr
        fill: fill
        stroke: fill
      .click (e) ->
        c = this.attr('fill')
        context.current_controller.color_.target_region.mesh.setColor [c.r/255,c.g/255,c.b/255,1]
        logger.log_event(type: 'pick_color', color:c, target: context.current_controller.color_.target_region.region_id)
      r+=1
    @paper.text(@paper.width-5,5,'X').click () => context.current_controller.color_.hide()
    logger.log_event(type: 'show_colors')
  
  
  hide: () ->
    @paper.canvas.style.opacity = 0
    @paper.canvas.style.left = ""+(-1000)+"px"
    logger.log_event(type: 'hide_colors')
    
  
