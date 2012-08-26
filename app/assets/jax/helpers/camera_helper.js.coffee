c = [0,0,0]     # Center point
a = 0           # horizonal/longitudinal Angle of camera position
h = 0           # vertical/latitudinal Height of the camera position
d = 30          # Depth/distance of camera from the center point
d_min   = 15
d_max   = 32.5
d_range = d_max-d_min
halfpi  = Math.PI/2
twopi   = Math.PI*2
anim    = false


Jax.getGlobal().CameraHelper = Jax.Helper.create
  camera_scroll: (event) ->
    unless anim
      d -= event.wheelDeltaY/100
      d = d_min if d < d_min
      d = d_max if d > d_max
    @tooltip.mouse_scrolled() if @tooltip
    
  camera_drag: (event) ->
    unless anim
      a += 0.02 * -event.diffx
      h += 0.02 * -event.diffy
      h = halfpi  if h > halfpi
      h = -halfpi if h < -halfpi
      @scene.highlight()
  
  camera_press: () -> 
    @press_position = {a:a, h:h, d:d}
  
  camera_release: () ->
    this.camera_moved() if a != @press_position.a or d != @press_position.d or h != @press_position.h
    
  configure_camera: (center_point, radius) ->
    c = center_point
    d_min = radius
    
  camera_position: (ca,ch,cd) -> # expects arguments scaled to 1
    if ca or ca==0
      a = twopi*(ca-Math.floor(ca))
    if ch or ch==0
      if ch > 1
        h = halfpi
      else if ch < -1
        h = -halfpi
      else
        h = ch * halfpi
    if cd or cd==0
      if cd > 1
        d = d_max
      else if cd < 0
        d = d_min
      else
        d = d_min + cd * d_range
    a: ca || a/twopi,
    h: ch || h/halfpi,
    d: cd || (d-d_min)/d_range
  
  animate: (ta,th,td,ms,ef,cb) ->
    # since any whole num
    start = this.camera_position()
    if not ms or (ta==start.a and th == start.h and td == start.d)
      return anim = false
    anim = 
      tt: ms              # total time
      et: 0               # elapsed time
      ta: ta              # target angle
      th: th              # target height
      td: td              # target distance
      ia: start.a         # initial angle
      ih: start.h         # initial height
      id: start.d         # initial distance
      da: ta-start.a      # angle difference
      dh: th-start.h      # height difference
      dd: td-start.d      # distance difference
      cb: cb              # callback
    if ef == "linear"      # easing function
      anim.ef = (t) -> t
    else if ef == "easing"
      anim.ef = (t) -> 0.5-(Math.cos(3*t)/2)
    else
      anim.ef = (t) -> t
    if ms?
      anim.td = 1  if td > 1
      anim.td = -1 if td < -1
      anim.th = 1  if th > 1
      anim.th = -1 if th < -1
    anim
  
  stop: -> anim = false
  
  update: (timechange) ->
    if anim
      if anim.tt-anim.et <= 0.05
        this.camera_position(anim.ta,anim.th,anim.td)
        callback = anim.cb
        this.animate()
        callback() if callback
      else
        progress = anim.ef((anim.et += timechange)/anim.tt)
        this.camera_position anim.ia + anim.da*progress,
                             anim.ih + anim.dh*progress,
                             anim.id + anim.dd*progress
    x = c[0] + d * Math.cos(h) * Math.sin(a)
    y = c[1] + d * Math.sin(h)
    z = c[2] + d * Math.cos(h) * Math.cos(a)
    @player.camera.lookAt c, [x,y,z]
    @player.lantern.camera.setPosition [x,y,z]
    if @labels
      @labels.camera.lookAt [x,y,z], c
        
      
  