Jax.views.push "Scene/index", ->
  #@context.gl.depthFunc GL_LESS
  @glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  @world.render()
