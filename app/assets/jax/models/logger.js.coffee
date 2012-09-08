Jax.getGlobal()['Logger'] = Jax.Model.create
  after_initialize: ->
    @log = {} # timestamp as key
  
  log_input_event: () ->
    # 
  
  log_app_event: () -> # e.g. change in url/state/view
    # {type, content}
    
  store_logs: () ->
    # attempt to post the logs to the server, on fail save them to indexedDB
  
