tabs_id = '#sup_tabs'
ntabs = 0

Jax.getGlobal().SupContentHelper = Jax.Helper.create
  
  sc_load_node: (thing_id, node_name, fire) ->
    $(tabs_id).tabs() # not sure why but this is neccessary...
    if thing_id
      url = '/ontology/things/'+thing_id+':node:embed'
    else
      url = '/node:'+node_name+':embed'
    $.ajax
      type: 'GET'
      url: url
      dataType: 'json'
      success: (data) =>
        this.sc_init_node(data, fire)
      error: (r) -> console.log("Couldn't fetch node") 
    
  sc_load_node_from_url: () ->
    node = window.location.pathname.split(':')[1]
    return false if @active_node == node
    this.sc_load_node null, node, false
  
  sc_init_node: (node_data, fire=true) ->
    unless node_data
      node_data = $('#sup_content').data('node')
      unless node_data
        return this.sc_load_node(61) # this shouldn't be hard coded!
    this.sc_clear_tabs
    this.sc_clear_tabs()
    this.sc_new_tab 'Notes',         node_data.embedded_node
    this.sc_new_tab 'Wikipedia',    "<iframe src='"+node_data.wikipedia_uri+"'></iframe>"    if node_data.wikipedia_uri
    this.sc_new_tab 'Scholarpedia', "<iframe src='"+node_data.scholarpedia_uri+"'></iframe>" if node_data.scholarpedia_uri
    this.sc_new_tab 'Resources',    "resources template goes here"
    $(tabs_id).tabs 'select', 0
    $(window).scroll() # this just triggers the javascript resize of the tabs
    @active_node = node_data.name
    this.node_changed() if fire
  
  sc_clear_tabs: () ->
    $(tabs_id).tabs('remove', i) for i in [ntabs-1..0]
    ntabs = 0
    
  sc_new_tab: (title, content) ->
    $(tabs_id).tabs('add', '#tab-'+title, title)
    .tabs 'select', ntabs
    $('#tab-'+title).html content
    ntabs+=1