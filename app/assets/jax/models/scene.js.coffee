Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    @region_set = []
    loader = AssetLoader.find "standard"
    console.log loader.test_load()