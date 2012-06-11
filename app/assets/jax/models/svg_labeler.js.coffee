isOnSegment = (xi,yi, xj,yj, xk,yk) ->
  (xi <= xk || xj <= xk) && (xk <= xi || xk <= xj) && (yi <= yk || yj <= yk) && (yk <= yi || yk <= yj)

directionFromLine = (xi,yi, xj,yj, xk,yk) ->
  a = (xk-xi)*(yj-yi)
  b = (xj-xi)*(yk-yi)
  if a < b then -1 else if a > b then 1 else 0

lineSegmentsIntersect = (x1,y1, x2,y2, x3,y3, x4,y4) ->
  d1 = directionFromLine(x3, y3, x4, y4, x1, y1)
  d2 = directionFromLine(x3, y3, x4, y4, x2, y2)
  d3 = directionFromLine(x1, y1, x2, y2, x3, y3)
  d4 = directionFromLine(x1, y1, x2, y2, x4, y4)
  (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
  ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) ||
  (d1 == 0 && isOnSegment(x3, y3, x4, y4, x1, y1)) ||
  (d2 == 0 && isOnSegment(x3, y3, x4, y4, x2, y2)) ||
  (d3 == 0 && isOnSegment(x1, y1, x2, y2, x3, y3)) ||
  (d4 == 0 && isOnSegment(x1, y1, x2, y2, x4, y4))


Jax.getGlobal()['SVGLabeler'] = Jax.Model.create
  after_initialize: ->
    @pressed = false
    @cleared = true
    
    # min r should scale with the shapeset size and camera distance
    @r_min = 200
    @r = @r_min
    @r_stepsize = 4
    @adjustment = true
    
    @bounds =
      x1: window.context.canvas.offsetLeft
      y1: window.context.canvas.offsetTop
      x2: window.context.canvas.width
      y2: window.context.canvas.height
    @c = 
      x: (@bounds.x2+@bounds.x1)/2
      y: (@bounds.y2+@bounds.y1)/2
    
    @paper = Raphael(@bounds.x1, @bounds.y1, @bounds.x2, @bounds.y2)
    $(@paper.canvas).css "pointer-events": "none"
    @labels = []
    @label_r = 8
    @style =
      "font":         "Helvetica"
      "font-size":    12
      "fill":         "#222"
      "text-anchor":  "middle"
    
    
  mouse_pressed: (e) ->
    @pressed = true
    this.clear()
  
  mouse_released: (e) ->
    @pressed = false
    this.source_labels()
    this.draw()
  
  mouse_exited: (e) ->
    if @pressed
      @pressed = false
      this.source_labels()
      this.draw()
  
  source_labels: () ->
    # determine all visible regions and populated {labels} with their centroids and names
    labels = window.context.world.find_region_centers()
    delete labels[0]
    @labels = []
    for l of labels
      @labels.push
        region: labels[l].region
        in:
          x: labels[l].x
          y: labels[l].y
        text: labels[l].region.name
  
  draw: () ->
    return false unless @cleared
    
    # determine label angles, dimensions and initial outer_positions
    for label in @labels
      x = label.in.x - @c.x
      y = label.in.y - @c.y
      len = Math.sqrt(x*x+y*y)
      x2 = @c.x+@r*x/len
      y2 = @c.y+@r*y/len
      vx = label.in.x-x2
      vy = label.in.y-y2
            
      label.out = {x: x2, y: y2}
      label.angle = Math.atan2 x, y
      label.length = Math.sqrt vx*vx+vy*vy
            
      bb = @paper.text(0,-1000,label.text).attr(@style).getBBox()
      label.w = bb.width+@label_r
      label.h = bb.height*1.2
    @paper.clear()
    
    @labels.sort (a,b) -> a.angle - b.angle
    
    # arrange labels
    while this.smooth() || this.untangle()
      while this.max_labels() < @labels.length
        # expand radius
        @r += @r_stepsize
        for label in @labels
          label.out.x = @c.x+@r*Math.sin(label.angle)
          label.out.y = @c.y+@r*Math.cos(label.angle)
        
        while !this.labels_fit()
          # prune labels (shortest first)
          i = -1
          label_lengths = []
          label_lengths.push [i+=1,l.length] for l in @labels
          label_lengths.sort (a,b) -> return a[1]-b[1]
          console.log @labels.length
          @labels.splice label_lengths[0][0], 1
          console.log @labels.length
          # reduce radius if possible
          @r -= @r_stepsize
          @r = @r_min if @r < @r_min
        
    for i in [0...@labels.length]
      label = @labels[i]
      if label.out.x > @c.x
        text_offset = label.w/2
        box_x = label.out.x
      else
        text_offset = -label.w/2
        box_x = label.out.x-label.w
    
      outside_y = if @adjustment then this.adjusted_y(i) else label.out.y
      
      label.graphic = @paper.set()
      label.graphic.push(
        @paper.circle(label.in.x,label.in.y,0.8),
        @paper.circle(label.out.x,outside_y,0.8)
        @paper.path([["M",label.in.x,label.in.y],["L",label.out.x,outside_y]])
        @paper.rect(box_x, outside_y-label.h/2, label.w, label.h, @label_r)
        @paper.text(label.out.x+text_offset, outside_y, label.text).attr(@style)
      )
  
  clear: () ->
    @paper.clear()
    @labels = {}
    @cleared = true
  
  adjusted_y: (i) ->
    radius = @r*0.76 + (@r-Math.abs(@labels[i].out.x-@c.x))/1.8
    @c.y+(radius*Math.cos(@labels[i].angle))
  
  max_labels: () -> 
    4*@r/@labels[0].h
  
  labels_fit: () ->
    # check whether the labels all fit on the paper
    for label in @labels
      return false if (label.out.x < @c.x && label.out.x-label.w < 1) ||
                      (label.out.x > @c.x && label.out.x+label.w > @bounds.x2-1) ||
                      this.adjusted_y(i)-label.h  < 1 || 
                      this.adjusted_y(i)+label.h  > @bounds.y2-1
    return true
  
  smooth: (iteration) ->
    # apply angle smoothing 
    smoothed_angles = []
    for i in [0...@labels.length]
      prev = @labels[i-1] || @labels[@labels.length-1]
      next = @labels[i+1] || @labels[0]
      step_x = (prev.out.x+@labels[i].out.x/2+next.out.x)/2.5
      step_y = (prev.out.y+@labels[i].out.y/2+next.out.y)/2.5
      smoothed_angles.push Math.atan2(step_x-@c.x, step_y-@c.y)
      
    # calculate correction_size
    correction_size = 0
    for i in [0...@labels.length]
      correction_size += Math.abs(@labels[i].angle - smoothed_angles[i])
    
    # apply correction if correction_size isn't too small
    if (apply = correction_size > 0.005)
      for i in [0...@labels.length]
        @labels[i].angle = smoothed_angles[i]
        @labels[i].out.x = @c.x+@r*Math.sin(smoothed_angles[i])
        @labels[i].out.y = @c.y+@r*Math.cos(smoothed_angles[i])
    
    return apply
  
  untangle: () ->
    # swap positions of any labels with intersecting lines
    swap = null
    
    # construct queue of line pairs to check, with the ends coming last
    q = []
    for i in [1...@labels.length]
      q.push i-1, i
      q.push i-1, i+1 if @labels[i+1]
      q.push i-1, i+2 if @labels[i+2]
    q.push @labels.length-1, 0
    q.push @labels.length-1, 1
    q.push @labels.length-1, 2
        
    while q.length
      i = q.shift()
      j = q.shift()
      a = @labels[i]
      b = @labels[j]
      if lineSegmentsIntersect(a.in.x,  a.in.y,
                               a.out.x, this.adjusted_y(i),
                               b.in.x,  b.in.y,
                               b.out.x, this.adjusted_y(j))
        swap =
          out:
            x: @labels[i].out.x
            y: @labels[i].out.y
          angle: @labels[i].angle
        @labels[i].out.x = @labels[j].out.x
        @labels[i].out.y = @labels[j].out.y
        @labels[i].angle = @labels[j].angle
        @labels[j].out.x = swap.out.x
        @labels[j].out.y = swap.out.y
        @labels[j].angle = swap.angle
        # rebuild q from scratch if changes made
        q = []
        q.push(i-1,i) for i in [1...@labels.length]
        q.push @labels.length-1, 0
    
    @labels.sort (a,b) -> a.angle-b.angle
    !!swap
  