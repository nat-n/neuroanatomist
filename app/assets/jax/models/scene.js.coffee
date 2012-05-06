Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    @region_set = []
    loader = AssetLoader.find "standard"
    loader.test_fetch()