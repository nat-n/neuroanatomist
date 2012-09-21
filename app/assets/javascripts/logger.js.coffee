
dump_logs: (ids,quiz=false) =>
  # dumps ids from window.logger.log and quiz stats from window.context.current_controller.qm.stats u<user_id>t<time>
  return false unless ids.length or quiz
  ulogs = (logger.log[id] for id in ids)
  stats = if context.current_controller.qm then context.current_controller.qm.quiz.stats else {}
  @idb.db.transaction(["logs"], "readwrite").objectStore("logs").put {sid:"u#{page_data.user}t#{Date.now}", logs:ulogs, stats:stats}

load_logs: () =>
  # load logs and quiz_stats and attempt to upload them
  # ••extend•• stored_logs with logs... this could cause errors in displayed stats if upload fails twice in a row without page reload!
  # if upload succeeds then remove them from idb

window.Logger = class Logger
  log: {}
  most_recent = 0
  quizzed = false
  constructor: () ->
      
  log_input: (event, props={}) ->
    props.type = event.type
    
    this.log_event(props)

  log_mouse: (event, props={}) ->
    props.type = event.type
    props.target = (event.target.localName+'.'+event.target.id)
    props.scrnX = event.screenX
    props.scrnY = event.screenY
    props.x = event.x
    props.y = event.y
    props.dx = event.diffx
    props.dy = event.diffy
    props.wd = event.wheelDelta
    this.log_event(props)
  
  log_quiz: (props) ->
    quizzed = true
    this.log_event props
  
  log_event: (props) -> # e.g. change in url/state/view
    props['ts'] = Date.now()
    props['u'] = page_data.user
    props['a'] = page_data.action
    @log[props['ts']] = props
    
  store_logs: (success=(()->)) ->
    # attempt to post the logs to the server, on fail save them to indexedDB
    upload_times = (time for time of @log)
    if @quizzed
      stats = $.extend context.current_controller.qm.quiz.stats_stored, context.current_controller.qm.quiz.stats #### THIS IS WRONG !!!
      context.current_controller.qm.quiz.stats = {}
    $.ajax
      type: 'POST'
      url:  '/user'
      data: {logs: (@log[time] for time in upload_times), stats:stats}
      success: (response) =>
        # clear log of uploaded times
        console.log response
        if response = "logs saved"
          for time in upload_times
            console.log @log[time]
            delete @log[time]
        success()
      error: () -> dump_logs(upload_times,@quizzed)

window.logger = new Logger()

window.onresize = (e) ->
  logger.log_input e,
    window_w: window.innerWidth
    window_h: window.innerWidth

window.onscroll = (e) ->
  logger.log_input e,
    scroll: $(window).scrollTop()

window.onunload = (e) ->
  logger.log_input e
  logger.store_logs()
  true

window.oncontextmenu = (e) ->
  logger.log_mouse e

