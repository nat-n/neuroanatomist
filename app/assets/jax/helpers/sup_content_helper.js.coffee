tabs_id = '#sup_tabs'
ntabs = 0

Jax.getGlobal().SupContentHelper = Jax.Helper.create
  
  sc_load_node: (thing_id) ->
    $(tabs_id).tabs() # not sure why but this is neccessary...
    $.ajax(
      type: 'GET'
      url: '/ontology/things/'+thing_id+':node:embed'
      dataType: 'json'
      success: (data) =>
        this.sc_init_node(data)
      error: (r) -> console.log("Couldn't fetch node")
    )
  
  #sc_init_node: 
  
  sc_init_node: (node_data) ->
    unless node_data
      node_data = $('#sup_content').data('node')
      return 0 unless node_data
    this.sc_clear_tabs
    this.sc_clear_tabs()
    this.sc_new_tab 'Node',         node_data.embedded_node
    this.sc_new_tab 'Wikipedia',    "<iframe src='"+node_data.wikipedia_uri+"'></iframe>" if node_data.wikipedia_uri
    this.sc_new_tab 'Scholarpedia', "<iframe src='"+node_data.scholarpedia_uri+"'></iframe>" if node_data.scholarpedia_uri
    this.sc_new_tab 'Resources',    "resources template goes here"
    $(tabs_id).tabs 'select', 0
    $(window).scroll() # this just triggers the javascript resize of the tabs
  
  sc_clear_tabs: () ->
    $(tabs_id).tabs('remove', i) for i in [ntabs-1..0]
    ntabs = 0
    
  sc_new_tab: (title, content) ->
    $(tabs_id).tabs('add', '#tab-'+title, title)
    .tabs 'select', ntabs
    $('#tab-'+title).html content
    ntabs+=1