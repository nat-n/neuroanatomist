Jax.getGlobal()['Region'] = Jax.Model.create
  after_initialize: ->
#    @name = "" 
#    @id   = 0
  
  compose: (region_def) ->
    this.id = region_def.id
    this.name = region_def.name
    model_data = borders: {}, faces: [], vertex_normals: [], vertex_positions: []
    @mesh = new Jax.Mesh
      color: [Math.random(),Math.random(),Math.random(),1]
      material: "scene"
      init: (vertices, colors, texCoords, normals, indices) ->
        if model_data
          vertices.push datum for datum in model_data["vertex_positions"]
          normals.push  datum for datum in model_data["vertex_normals"]
          indices.push  datum for datum in model_data["faces"]
      update: ((updated_model_data) => model_data = updated_model_data; @mesh.rebuild())
        
    shape_vvs = []
    # construct array of meshes included in this region
    meshes = []
    for more_meshes in ((shape_vvs.push(shape["volume_value"]) and shape["meshes"]) for shape in region_def["shapes"])
      meshes = meshes.concat (mesh for mesh in more_meshes when mesh.included != "no")
    
    # filter out internal meshes
    meshes = (mesh for mesh in meshes when ((mesh,meshes) ->
      fb = mesh["name"].split("-")
      not((fb[0] in shape_vvs) and (fb[1] in shape_vvs)))(mesh,meshes))
    
    # compose mesh and update
    for mesh in meshes
      # find mesh data
      mesh = window.JAS.meshes[mesh.id]
      # ensure normals face outwards
      if mesh["name"].split("-")[0] in shape_vvs
        mesh["vertex_normals"] = (-vn for vn in mesh["vertex_normals"])
      model_data = this.stitch(model_data, mesh)
    
    @mesh.update model_data
    return this
  
  
  stitch: (model_data, mesh) ->
    # determine shared borders
    shared_borders = (bi for bi of mesh.borders when bi of model_data.borders)
    all_border_vi = []
    all_border_vi = all_border_vi.concat mesh.borders[bi] for bi of mesh.borders when bi in shared_borders
    index_map = {}
    
    # reindex border vertices
    for bi in shared_borders
      i = -1
      for bvi in mesh.borders[bi]
        i++
        index_map[bvi] = model_data.borders[bi][i]
    
    new_index = model_data.vertex_positions.length/3-1
    for vi in [0...mesh.vertex_positions.length/3]
      unless vi in all_border_vi
        # reindex remaining vertices
        index_map[vi] = new_index+=1
        # copy over vertices and normals
        vi3 = vi*3
        model_data.vertex_positions.push vp for vp in mesh.vertex_positions[vi3..vi3+2]
        model_data.vertex_normals.push vn for vn in mesh.vertex_normals[vi3..vi3+2]
    
    # remap and copy faces
    model_data.faces.push index_map[fi] for fi in mesh.faces
    
    # remap and copy borders
    for bi of mesh.borders
      unless bi in shared_borders
        model_data.borders[bi] = index_map[bvi] for bvi in mesh.borders
    
    return model_data    