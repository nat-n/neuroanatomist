Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    loader = AssetLoader.find "standard"
    
    @shape_set = loader.load_shape_set "default"
    @region_set = @shape_set["default_region_set"]
      
  region_set: ->
    @region_set
