# use torus like template, there's a maximum number of points where a label can be places for any

Jax.getGlobal()['LabelRing'] = Jax.Model.create
  after_initialize: ->
    labels = {}
    model_data = null
    #@mesh = new Jax.Mesh.Torus
    #  inner_radius: 1
    #  outer_radius: 11
    #  rings: 10
    #  sides: 2
    
    #@mesh = new Jax.Mesh
    #  color: [Math.random(),Math.random(),Math.random(),1]
    #  material: "scene"
    #  init: (vertices, colors, texCoords, normals, indices) ->
    #    build_circle(20)
    #    if model_data
    #      vertices.push datum for datum in model_data["vertex_positions"]
    #      normals.push  datum for datum in model_data["vertex_normals"]
    #      indices.push  datum for datum in model_data["faces"]
    #  update: ((updated_model_data) => model_data = updated_model_data; @mesh.rebuild())
  
  
  add_label: (source, content) ->
    labels[source] = content
  
  build_circle: (n,r,c) ->
    # describes a circle with n points, r radius
    # circle is assumed to be normal to the z axis
    points = n || 10
    radius = r || 11
    center = c || [0,0,0]
     
    