movement = 
  forward: 0
  backward: 0
  left: 0
  right: 0

speed_key = 3

Jax.getGlobal().UserMovementHelper = Jax.Helper.create
  mouse_dragged: (event) ->
    @player.camera.pitch 0.01 *  event.diffy
    @player.camera.yaw   0.01 * -event.diffx
  
  key_pressed: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then movement.forward  =  1
      when KeyEvent.DOM_VK_S then movement.backward = -1
      when KeyEvent.DOM_VK_A then movement.left     = -1
      when KeyEvent.DOM_VK_D then movement.right    =  1
      when KeyEvent.DOM_VK_1 then speed_key         =  1
      when KeyEvent.DOM_VK_2 then speed_key         =  2
      when KeyEvent.DOM_VK_3 then speed_key         =  3
      when KeyEvent.DOM_VK_4 then speed_key         =  4
      when KeyEvent.DOM_VK_5 then speed_key         =  5
      when KeyEvent.DOM_VK_6 then speed_key         =  6
      when KeyEvent.DOM_VK_7 then speed_key         =  7
      when KeyEvent.DOM_VK_8 then speed_key         =  8
      when KeyEvent.DOM_VK_9 then speed_key         =  9
 
  key_released: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then movement.forward  = 0
      when KeyEvent.DOM_VK_S then movement.backward = 0
      when KeyEvent.DOM_VK_A then movement.left     = 0
      when KeyEvent.DOM_VK_D then movement.right    = 0
  
  update: (timechange) ->
    speed = 0.5 * speed_key * timechange
  
    @player.camera.move (movement.forward + movement.backward) * speed
    @player.camera.strafe (movement.left + movement.right) * speed
    if @player.lantern
      # reposition the lantern to the player's location
      @player.lantern.camera.setPosition @player.camera.getPosition()
