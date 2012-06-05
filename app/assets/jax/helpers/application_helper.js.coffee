Jax.getGlobal().ApplicationHelper = Jax.Helper.create
  patch_world: ->
    Jax.World.prototype.pick_all_visible = () ->
      context = this.context
      w = context.canvas.width
      h = context.canvas.height
      data = new Uint8Array(w*h*4)
      data.w = w
      data.h = h
      data.f = f = 4
      pickBuffer = new Jax.Framebuffer
        width:  w
        height: h
        depth:  true
      
      pickBuffer.bind context, () ->
        pickBuffer.viewport(context)
        context.gl.clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        context.gl.disable(GL_BLEND)
        context.world.render({material:"picking"})
        context.gl.readPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data)
        data = data.data if data.data

      # restore the visible viewport and blending
      context.gl.viewport 0, 0, w, h
      context.gl.enable GL_BLEND
      
      # pick all visible
      ary = []
      i = -2
      while i < data.length
        i+=4
        if data[i] > 0
          index = Jax.Util.decodePickingColor data[i-2], data[i-1], data[i], data[i+1]
          if index != undefined && ary.indexOf(index) == -1
            ary.push(index)
      
      # show pickBuffer
      unless document.getElementById("debug_canvas")
        $('#content').append($('<canvas id="debug_canvas", width="'+w+'", height="'+h+'"></canvas>'))
      debug_context = document.getElementById("debug_canvas").getContext('2d')
      imagedata = debug_context.getImageData 0, 0, w, h
      
      # data needs to be flipped vertically as it's loaded into imagedata
      bytesPerLine = w*4
      dr = data.length
      for r in [0...data.length] by bytesPerLine
        dr -= bytesPerLine
        for c in [0...w*4] by 4
          i = r+c
          di = dr+c
          imagedata.data[i]   = data[di]
          imagedata.data[i+1] = data[di+1]
          imagedata.data[i+2] = data[di+2]
          imagedata.data[i+3] = data[di+3]
          
      debug_context.putImageData imagedata, 0, 0
      
      # attempt to find region centers by transformation
      for i in ary
        c = this.region_center context.world.getObject(i)
        console.log c
        debug_context.fillRect c[0]+w/2, c[1]+h/2, 1, 1
      
      return ary
    


    Jax.World.prototype.region_center = (model) ->
      center = new Float32Array(4)
      center[3] = 1 # initialize to [0, 0, 0, 1]
            
      bounds = model.mesh.getBounds()
      center[0] = (bounds.left + bounds.right) / 2
      center[1] = (bounds.top + bounds.bottom) / 2
      center[2] = (bounds.front + bounds.back) / 2
      
      # convert `center` from object space to world space
      mat4.multiplyVec4 model.camera.getTransformationMatrix(), center, center
      # convert `center` from world space into camera space
      mat4.multiplyVec4 this.context.player.camera.getTransformationMatrix(), center, center
      # convert `center` from camera space into screen space
      mat4.multiplyVec4 this.context.player.camera.getProjectionMatrix(), center, center
      
      # divide x, y, z by w to get normalized device coordinates (NDC)
      vec3.scale center, 1 / center[3]

      # now x, y and z are all between -1 and 1. Multiply by canvas size:
      center[0] *= this.context.canvas.width  / 2
      center[1] *= this.context.canvas.height / 2
      
      return center