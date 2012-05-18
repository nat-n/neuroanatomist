# maybe the scene and region models should manage the highlight effect etc 

c = [0,0,0]
a = 0
h = 0
d = 30
min_d = 15
max_d = 40
half_pi = Math.PI/2

Jax.getGlobal().ObjectMovementHelper = Jax.Helper.create
  key_pressed: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then d -= 1
      when KeyEvent.DOM_VK_S then d += 1
    d = min_d if d < min_d
    d = max_d if d > max_d
  
  mouse_dragged: (event) ->
    a += 0.02 * -event.diffx
    h += 0.02 * -event.diffy
    h = half_pi  if h > half_pi
    h = -half_pi if h < -half_pi
    @scene.highlight()
    if @tooltip
      @tooltip.mouse_dragged event.pageX, event.pageY, @picked
  
  update: (timechange) ->
    x = c[0] + d * Math.cos(h) * Math.sin(a)
    y = c[1] + d * Math.sin(h)
    z = c[2] + d * Math.cos(h) * Math.cos(a)
    @player.camera.lookAt c, [x,y,z]
    @player.lantern.camera.setPosition [x,y,z]
  
  camera_poistion: (ca,ch,cd) ->
    a = ca if ca
    h = ch if ch
    d = cd if cd
    [a,h,d]
  
  animate: (ta,th,td,callback) ->
    