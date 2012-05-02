Jax.getGlobal()['Region'] = Jax.Model.create
  after_initialize: ->
      
      
    
  validate_region: ->
    
  
  cache_region: ->
    
  
  formulate_region: ()->
    # determine exactly which meshes are required
  
  compose: (region_def)->
    # this is where we get down to business
    # a region is defined by a set of shapes to be stitched together into one solid shape
    # though it would be very nice to be able to define subregions which can be picked and manipulated individually!!!
    # the region def should really specify exactly which meshes are inccured, so there needs to be another method for 
    # => working this out from the shape set
    
    
    # given a set of shapes, which are neighbors? 
    # => maybe need to construct a shape adjecency graph somewhere?
    
    # need to determine which meshes are internal so can be ignored fromt the start!!!
    
    # ask asset loader for meshes
    
    # quite simply discard meshes which appear twice or which reference two shapes in the region