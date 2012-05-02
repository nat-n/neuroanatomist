Jax.getGlobal()['AssetLoader'] = Jax.Model.create
  after_initialize: ->
    # this model is responsible for finding, fetching and returning requested meshes, regions, descriptions, indexes etc
    # particularly in service of scene and region
    # also responsible for local caching of assets
    # can bundle assets into a single request to the server to reduce overhead
    
    
    
  load_shape_set: ->
    # checks for more recent versions of the shape_set
    # retrieves shapeset.index
    #   this includes the meta_data, and graph of a shape set.
    # also retrieves meshes of the the default region_set of the shape_set, which is specified in the metadata
    
  
  load_meshes: (assets) ->
    
    
  load_regions: (assets) ->
    # there is a large index of regions on the server
    # user creation of regions would be a nice feature, they can then be uploaded and given a universal region id
    
    
    
    
  
  
  load: () ->
    # takes a hash of loadable items and processes them all, requiring only <= 1 iDB transaction and <=1 AJAX request.
    # all other loaders use this method!!!