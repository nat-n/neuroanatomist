describe "SceneController", ->
  controller = null
  
  beforeEach ->
    SPEC_CONTEXT.redirectTo "scene/index"
    controller = SPEC_CONTEXT.current_controller
  
  it "should do something", ->
    expect(controller).toBeKindOf(Jax.Controller)
