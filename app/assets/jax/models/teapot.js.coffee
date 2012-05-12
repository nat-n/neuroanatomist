Jax.getGlobal()['Teapot'] = Jax.Model.create
  after_initialize: ->
    @mesh = new Jax.Mesh.Teapot
      material: "teapot"
      position: [0, 0, 0]
