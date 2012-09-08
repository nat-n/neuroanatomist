describe "Logger", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Logger()
      
  
  it "should instantiate without errors", ->
    expect(-> new Logger()).not.toThrow()
  