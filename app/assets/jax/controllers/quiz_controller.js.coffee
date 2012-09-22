extend_name = (name) ->
  if name.substring(0,3) is "L. "
    name.replace("L. ","Left ")
  else
    name.replace("R. ","Right ")

abrv_name = (name) ->
  if name.substring(0,5) is "Left "
    name.replace("Left ", "L. ")
  else
    name.replace("Right ","R. ") 

Jax.Controller.create "Quiz", ApplicationController,
  index: ->
    logger.log_event(type: 'quiz_index')
    $('#label_type_labels').attr 'disabled', true
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
    @accessible = ([r,extend_name(region_data[r].name)] for r of region_data when region_data[r].a)
    @accessible = @accessible.sortBy(1)
    @viewable = ([r,extend_name(region_data[r].name), region_data[r].p] for r of region_data when region_data[r].p)
    @viewable = @viewable.sortBy(1)
    
    @qm.update_status("Loading quiz data...")
    setTimeout (()=>@loader.idb.init(()=>setTimeout((()=>this.start()), 100))), 200
    
  
  helpers: -> [ CameraHelper, CanvasEventRoutingHelper, PerspectiveHelper, GeneralEventRoutingHelper, StatusHelper, SceneHelper ]
  
  start: (tried_loading=false) ->
    logger.log_event(type: 'quiz_start')
    this.show_loading_spinner($('#visualisation'), true)
    
    return @loader.idb.load_everything(()=>this.start(true)) unless tried_loading
    
    shape_set =  $('#visualisation').data('shapeSet')
    perspective_id =  $('#visualisation').data('perspectiveId')
    
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
          this.preload_quiz_content()
          this.hide_loading_spinner()
    else
      this.activate_shape_set shape_set_id
      @loader.fetch_perspective shape_set_id, perspective_id, (data, textStatus, jqXHR) =>
        this.load_perspective(perspective_id, false, true)
        this.preload_quiz_content()
        this.hide_loading_spinner()
      
  preload_quiz_content: () ->
    logger.log_event(type: 'quiz_preloading')
    this.update_quiz_mode()
    region_data = $('#target_list').data('regions')
    p_ids = (region_data[r].p for r of region_data when region_data[r].p)
    @loader.fetch_perspectives @active_shape_set, p_ids, () =>
      r_ids = (r for r of region_data when region_data[r].a)
      @loader.fetch_regions @active_shape_set, r_ids, () =>
        for r_id of region_data
          @s3[@active_shape_set].regions[r_id].default_perspective = region_data[r_id].p if region_data[r_id].p
        @qm.update_status("Click to start!")
        @qm.ready = true
        logger.log_event(type: 'quiz_preloaded')
  
  activate_tooltip: () ->
    if @labeler
      @labeler.clear()
    @tooltip = @tooltip_
    @labeler = null
    logger.log_event(type: 'activate_tt')
  
  update_quiz_mode: () ->
    # load stats from DOM if there aren't any others yet
    dom_stats = $('#target_list').data('quizStats')
    if $.isEmptyObject(@qm.quiz.stats) and not $.isEmptyObject(dom_stats)
      @qm.quiz.stats[region_name.replace(/;/g," ")] = dom_stats[region_name] for region_name of dom_stats
    logger.store_logs() # moves stats from @qm.quiz.stats_new into @qm.quiz.stats
    
    if $('input[name=quiz_modes]:checked').attr('id') is "search_mode"
      @qm.quiz.mode = "search"
      quizable = @accessible
    else if $('input[name=quiz_modes]:checked').attr('id') is "mcq_mode"
      @qm.quiz.mode = "mcq"
      quizable = @viewable
    $('#target_list table').show()
    $('#target_list tbody').html("")
    for r in quizable
      stats = (@qm.quiz.stats[abrv_name(r[1])] or @qm.quiz.stats[r[1]])
      correct = 0
      total   = 0
      for m of stats
        correct += (stats[m][0])
        total   += (stats[m][1])
      percentage = Math.round((correct/(total))*100)
      unless total then percentage = '-'
      else percentage = percentage+'%' 
      
      $('#target_list tbody').append $("<tr><td class='label_cell'><label for='target_"+r[0]+"'>"+r[1]+"</label></td><td><input type='checkbox' id='target_"+r[0]+"' checked='checked'/></td><td>#{total}</td><td>#{percentage}</td></tr>")
    $('#quiz_list td label, #quiz_list td input[type=checkbox]').click (e) ->
      e.stopImmediatePropagation()
      logger.log_event(type: 'quiz_list_check', label: this.labels[0].innerHTML, checked: this.checked) if this.type
    $('#quiz_list td').click (e)-> 
      c = !$(this).parent().children().children('input[type=checkbox]').attr('checked')
      $(this).parent().children().children('input[type=checkbox]').attr('checked',c)
      logger.log_event(type: 'quiz_list_check', label: $(this).parent().children().children()[0].innerHTML, checked: c)
    logger.log_event(type: 'quiz_mode', mode:@qm.quiz.mode)
    
    
    
    