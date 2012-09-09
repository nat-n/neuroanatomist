Jax.Controller.create "Quiz", ApplicationController,
  index: ->
    @active_shape_set = false
    @active_perspective = false
    @init_complete = false
    @mode = null
    @context.gl.clearColor(0.0, 0.0, 0.0, 0.0)
    @loader = AssetLoader.find "standard"
    @scene = Scene.find "primary"
    @tooltip_ = SVGTooltip.find "options"
    @labeler_ = SVGLabeler.find "regions_light"
    @color_ = Color.find "standard"
    this.activate_tooltip()
    @history = window.context.history ?= { log: [], back: [], forward: [], current: -1 }
    @s3 = window.context.s3 ?= {}
    @activity = (() =>
      c = 0
      updated = {}
      new: ()-> c = (c+1) or 1
      end: (new_updated, callback) ->
        setTimeout (() =>
          for ss of new_updated
            updated[ss] ?= []
            updated[ss].push os for os in new_updated[ss]
            updated[ss].uniq()
          (c-=1) or ((callback() or true) and updated = {})),
          500 # wait half a second to make sure no new activities are starting immediately
      empty: () -> c<1
      updated: () -> updated
    )()
    
    @world.addLightSource @player.lantern = LightSource.find "headlamp"
    
    @url_updating = false
    @show_hover = true
    
    this.patch_world()
    
    @qm = QuizMaster.find('select')
    
    region_data = $('#target_list').data('regions')
    @accessible = ([r,(if region_data[r].name.substring(0,3) is "L. " then region_data[r].name.replace("L. ","Left ") else region_data[r].name.replace("R. ","Right "))] for r of region_data when region_data[r].a)
    @accessible = @accessible.sortBy(1)
    @viewable = ([r,(if region_data[r].name.substring(0,3) is "L. " then region_data[r].name.replace("L. ","Left ") else region_data[r].name.replace("R. ","Right ")), region_data[r].p] for r of region_data when region_data[r].p)
    @viewable = @viewable.sortBy(1)

    setTimeout (()=>@loader.idb.init(()=>setTimeout((()=>this.start()), 100))), 200
    
    this.update_quiz_mode()
  
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper, PerspectiveHelper, GeneralEventRoutingHelper, SupContentHelper, StatusHelper, SceneHelper ]
  
  start: (tried_loading=false) ->
    this.show_loading_spinner($('#visualisation'), true)
    
    return @loader.idb.load_everything(()=>this.start(true)) unless tried_loading
    
    shape_set =  $('#visualisation').data('shapeSet')
    perspective_id =  $('#visualisation').data('perspectiveId')
    
    unless this.load_perspective_from_url()
      @loader.cache_shape_set(shape_set) if shape_set
      shape_set_id = try shape_set.id catch err
        null
    
      init_params = 
        shape_set: shape_set_id 
        requests: [
          type:"perspective"
          id: perspective_id
          cascade:"yes" ]
      
      unless perspective_id and shape_set_id
        @loader.fetch_defaults (data, textStatus, jqXHR) =>
          shape_set_id    = shape_set_id or data.default_shape_set.id
          perspective_id  = perspective_id or data.default_shape_set.default_perspective
          this.activate_shape_set shape_set_id
          @loader.fetch_perspective shape_set_id, perspective_id, (data, textStatus, jqXHR) => 
            this.load_perspective(perspective_id, false, true)
            this.hide_loading_spinner()
      else
        this.activate_shape_set shape_set_id
        @loader.fetch_perspective shape_set_id, perspective_id, (data, textStatus, jqXHR) =>
          this.load_perspective(perspective_id, false, true)
          this.hide_loading_spinner()
    
  
  activate_tooltip: () ->
    if @labeler
      @labeler.clear()
    @tooltip = @tooltip_
    @labeler = null
    
  activate_labels: () ->
    @labeler = @labeler_
    @tooltip.clear()
    @tooltip = null
    @labeler.pressed = false
    @labeler.source_labels()
    @labeler.draw()
  
  update_quiz_mode: () ->
    if $('input[name=quiz_modes]:checked').attr('id') is "search_mode"
      @qm.quiz.mode = "search"
      quizable = @accessible
    else if $('input[name=quiz_modes]:checked').attr('id') is "mcq_mode"
      @qm.quiz.mode = "mcq"
      quizable = @viewable
    $('#target_list ul').html("")
    for r in quizable
      $('#target_list ul').append $("<li><label for='target_"+r[0]+"'>"+r[1]+"</label><input type='checkbox' id='target_"+r[0]+"' checked='checked'/></li>")
    $('#quiz_list li label, #quiz_list li input[type=checkbox]').click((e) -> e.stopImmediatePropagation())
    $('#quiz_list li').click((e)->$(this).children('input[type=checkbox]').attr('checked',!$(this).children('input[type=checkbox]').attr('checked')))
    
      #<% @quiz_list.each do |n,r| %>
      #<li>
      #  <%= label :target, n, r %>
      #  <%= check_box :target, n, :checked=>true %>
      #</li>    
      #<% end %>
      #
  
