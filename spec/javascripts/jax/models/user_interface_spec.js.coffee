describe "UserInterface", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new UserInterface()
      
  
  it "should instantiate without errors", ->
    expect(-> new UserInterface()).not.toThrow()
  