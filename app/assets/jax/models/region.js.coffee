Jax.getGlobal()['Region'] = Jax.Model.create
  after_initialize: ->
    @id = @__unique_id
    @s3 = window.context.s3
    @color = false
    until @color
      color = Raphael.color r:Math.random(), g:Math.random(), b:Math.random()
      @color = [color.r,color.g,color.b,1] if color.s > 0.45 and color.v > 0.45 
    
  compose: (shape_set_id, region_id) ->
    @shape_set_id = shape_set_id
    @region_id = region_id
    region_def = @s3[@shape_set_id].regions[@region_id]
    if region_def.object then return region_def.object
    else region_def.object = this
    @name = region_def.name
    @decompositions = region_def.decompositions
    @thing = region_def.thing
    model_data = borders: {}, faces: [], vertex_normals: [], vertex_positions: []
    @mesh = new Jax.Mesh
      material: "scene"
      color: @color
      init: (vertices, colors, texCoords, normals, indices) =>
        if model_data
          vertices.push datum for datum in model_data["vertex_positions"]
          normals.push  datum for datum in model_data["vertex_normals"]
          indices.push  datum for datum in model_data["faces"]
      update: (updated_model_data) => 
        model_data = updated_model_data if updated_model_data
        @mesh.rebuild()
      
    model_data.shapes = []
    # construct array of meshes included in this region
    meshes = []
    for shape in (@s3[@shape_set_id].shapes[shape_id] for shape_id in region_def["shapes"])
      model_data.shapes.push(shape["volume_value"])
      meshes.push mesh for mesh in (@s3[@shape_set_id].meshes[mesh_id] for mesh_id in shape.meshes)
    
    # filter out internal meshes
    meshes = (mesh for mesh in meshes when ((mesh,meshes) ->
      fb = mesh["name"].split("-")
      not((fb[0] in model_data.shapes) and (fb[1] in model_data.shapes)))(mesh,meshes))
    
    # compose mesh and update
    model_data = this.stitch(model_data, @s3[@shape_set_id].meshes[mesh.id]) for mesh in meshes
    
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
      i = 0
      index_map[bvi] = model_data.borders[bi][i++] for bvi in mesh.borders[bi]
    
    new_index = model_data.vertex_positions.length/3-1
    for vi in [0...mesh.vertex_positions.length/3]
      unless vi in all_border_vi
        # reindex remaining vertices
        index_map[vi] = new_index+=1
        # copy over vertices and normals
        vi3 = vi*3
        model_data.vertex_positions.push vp for vp in mesh.vertex_positions[vi3..vi3+2]
        # ensure normals face outwards
        if model_data.shapes and mesh["name"].split("-")[0] in model_data.shapes
          model_data.vertex_normals.push -vn for vn in mesh.vertex_normals[vi3..vi3+2]
        else
          model_data.vertex_normals.push vn for vn in mesh.vertex_normals[vi3..vi3+2]
    
    # remap and copy faces
    model_data.faces.push index_map[fi] for fi in mesh.faces
    
    # remap and copy borders
    for bi of mesh.borders
      unless bi in shared_borders
        model_data.borders[bi] = index_map[bvi] for bvi in mesh.borders
    
    return model_data    