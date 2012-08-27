Jax.getGlobal().ApplicationHelper = Jax.Helper.create
  get_param: (name) ->
    results = RegExp("[\\?&]" + name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]") + "=([^&#]*)").exec(window.location.href)
    return results[1] if results
    null

  patch_world: ->    
    Array.prototype.uniq = () ->
      arr = this.sort (a, b) -> a*1 - b*1
      ret = [arr[0]]
      for i in [1..arr.length-1]
        ret.push arr[i] if arr[i-1] != arr[i]
      ret;
      
    Jax.World.prototype.find_region_centers = () ->
      show_debug_view = window.location.href.split("?")[1] and window.location.href.split("?")[1].split("&").indexOf("debug")>=0
      
      context = this.context
      w = context.canvas.width
      h = context.canvas.height
      f = 4
      wf = w*f
      data = new Uint8Array(w*h*4)
      pickBuffer = new Jax.Framebuffer
        width:  w
        height: h
        depth:  true
      
      pickBuffer.bind context, () ->
        pickBuffer.viewport(context)
        context.gl.clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        context.gl.disable(GL_BLEND)
        #context.gl.depthFunc GL_LESS
        context.world.render({material:"picking"})
        context.gl.readPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data)
        data = data.data if data.data

      # restore the visible viewport and blending
      context.gl.viewport 0, 0, w, h
      context.gl.enable GL_BLEND
      
      # find all visible border pixels by region and count total of each colour
      #regions = {} # should maybe calculate bounding box instead?
      borders_sites = []
      for i in [0...data.length] by f
        gi = i+1
        #regions[data[gi]] = regions[data[gi]] or 0
        #regions[data[gi]].total += 1
        if data[gi] and data[gi-f] != data[gi] or data[gi] != data[gi+wf] && Math.random()<0.5 #is border (top, left side only)
          quater_i = Math.floor(i/4)
          borders_sites.push {x:quater_i%w, y:Math.ceil(quater_i/w)} # voronoi diagram is in canvas space
      
      V = new Voronoi()
      bbox = {xl:0, xr:w, yt:0, yb:h}
      diagram = V.compute(borders_sites, bbox)
      
      if show_debug_view
        window.debug_paper = Raphael(650,50,w,h) unless window.debug_paper
        debug_paper = window.debug_paper
        debug_paper.clear()
      
      centers = {}
      # extract intersection points keeping only the best one for each region
      for edge in diagram.edges
        x = edge.va.x
        y = edge.va.y
        
        
        continue if x == bbox.xl || x == bbox.xr || y == bbox.yt || y == bbox.yb || !edge.lSite 
        
        
        # determine site distance (all sites should be at the same distance)
        d = Math.sqrt(Math.pow(x-edge.lSite.x,2)+Math.pow(y-edge.lSite.y,2))
        
        
        # determine region (green value) at this point
        continue unless g = data[Math.floor(y)*w*f + Math.floor(x)*f + 1] # get coords of red
        
        
        if show_debug_view
          #debug_paper.circle(edge.va.x,edge.va.y,d).attr(opacity: 0.3) if d>10
          debug_paper.rect(edge.lSite.x-0.5,h-edge.lSite.y-0.5,1,1).attr(opacity: 0.2)
        
        continue unless d > 5
        #debug_paper.path([["M", edge.va.x, h-edge.va.y], ["L", edge.vb.x, h-edge.vb.y]]).attr(opacity: 0.1, fill: "red")
        
        centers[g] = centers[g] || {x:x, y:h-y, d:d}
        if d > centers[g].d
          centers[g] = {x:x, y:h-y, d:d}
      
      for r of centers
        if show_debug_view
          debug_paper.circle(centers[r].x,centers[r].y,centers[r].d)
        centers[r].region = this.getObject(r)
      
      if show_debug_view
        # show pickBuffer
        debug_context = document.getElementById("debug").getContext('2d')
        imagedata = debug_context.getImageData 0, 0, w, h
        
        # data needs to be flipped vertically as it's loaded into imagedata
        bytesPerLine = w*4
        dr = data.length
        for r in [0...data.length] by bytesPerLine
          dr -= bytesPerLine
          for c in [0...w*4] by 4
            di = dr+c
            i = r+c
            gi = i+1
            #unless data[gi] and data[gi-f] != data[gi] or data[gi] != data[gi+wf]
            imagedata.data[i]   = data[di]
            imagedata.data[i+1] = data[di+1]
            imagedata.data[i+2] = data[di+2]*2
            imagedata.data[i+3] = data[di+3]
            #else
            #  imagedata.data[i]   = data[di]
            #  imagedata.data[i+1] = data[di+2]
            #  imagedata.data[i+2] = data[di+1]
            #  imagedata.data[i+3] = data[di+3]
            
        debug_context.putImageData imagedata, 0, 0
              
      return centers
