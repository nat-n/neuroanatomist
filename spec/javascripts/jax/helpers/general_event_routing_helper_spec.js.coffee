describe "GeneralEventRoutingHelper", ->
  helper = null 
 
  beforeEach ->
    klass = Jax.Class.create helpers: [ GeneralEventRoutingHelper ]
    helper = new klass
  
  # it "should sum 1+1", -> expect(helper.sum 1, 1).toEqual(2)
