
window.dump_logs = (ids,quiz_stats) =>
  # dumps ids from window.logger.log and quiz stats from window.context.current_controller.qm.stats u<user_id>t<time>
  return false unless ids.length or quiz_stats
  ulogs = (logger.log[id] for id in ids)
  context.current_controller.loader.idb.db.transaction(["logs"], "readwrite").objectStore("logs").put
    sid:        "u#{page_data.user}t#{Date.now}"
    logs:       ulogs
    quiz_stats: quiz_stats

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
    @quizzed = true
    this.log_event props
  
  log_event: (props) -> # e.g. change in url/state/view
    props['ts'] = Date.now()
    props['u'] = page_data.user
    props['a'] = page_data.action
    @log[props['ts']] = props
    
  store_logs: (success=(()->)) ->
    # attempt to post the logs to the server, on fail save them to indexedDB
    upload_times = (time for time of @log)
    data = {logs: (@log[time] for time in upload_times)}
    if @quizzed and context.current_controller.qm
      data.quiz_stats = context.current_controller.qm.quiz.new_stats
    copy_stats = () ->
      quiz = context.current_controller.qm.quiz
      for r of quiz.new_stats
        quiz.stats[r] ?= {}
        for m of quiz.new_stats[r]
          quiz.stats[r][m] ?= [0,0]
          quiz.stats[r][m][0] += quiz.new_stats[r][m][0]
          quiz.stats[r][m][1] += quiz.new_stats[r][m][1]
      quiz.new_stats = {}
    $.ajax
      type: 'POST'
      url:  '/user'
      data: data
      success: (response) =>
        # clear log of uploaded times
        console.log response
        if response = "logs saved"
          for time in upload_times
            delete @log[time]
        copy_stats()
        success()
      error: () ->
        dump_logs(upload_times,context.current_controller.qm.quiz.new_stats)
        copy_stats()

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

