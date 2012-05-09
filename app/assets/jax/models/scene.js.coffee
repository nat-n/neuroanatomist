Jax.getGlobal()['Scene'] = Jax.Model.create
  after_initialize: ->
    @active_regions = []
      
      
    # fetch data for the default region_set
    # compose the regions
    # add composed reqions to the world
    
  add_region: (region) ->
    @active_regions.push region
  
  active_regions: ()->
    @active_regions