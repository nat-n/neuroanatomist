Jax.getGlobal()['Region'] = Jax.Model.create
  after_initialize: ->
    @id = @__unique_id
    @s3 = window.context.s3
    @color = false
    
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
    
    @mesh_ids = (mesh.id for mesh in meshes)
    
    neighbor_colors = (n.color for n in this.neighbors())
    
    #colour_distance = (c1,c2) ->
    #  a = (c1[0]-c2[0])*2
    #  b = c1[1]-c2[1]
    #  c = c1[2]-c2[2]
    #  Math.sqrt(a*a+b*b+c*c)
    
    until @color
      c1 = [Math.random(),Math.random(),Math.random(),1]
      color = Raphael.color r:c1[0], g:c1[1], b:c1[2]
      if color.s > 0.45 and color.v > 0.45
        #min = 9
        #for nc in neighbor_colors
        #  min = Math.min(min,colour_distance(c1,nc))
        #console.log min
        @color = c1# if min > 0.3
    
    # compose and build mesh
    model_data = this.stitch(model_data, @s3[@shape_set_id].meshes[mesh.id]) for mesh in meshes
    
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
    
    #@mesh.update model_data
    return this
  
  neighbors: () ->
    # find existing regions with in_shapes that include one of this region's out_shapes
    ns = []
    for o of context.current_controller.scene.all_regions
      matched = false
      other = context.current_controller.scene.all_regions[o]
      for mesh_id in @mesh_ids
        continue if matched
        ((matched=true) and ns.push(other)) if mesh_id in other.mesh_ids
    return ns
      
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
    should_reverse = model_data.shapes and mesh["name"].split("-")[0] in model_data.shapes
    for vi in [0...mesh.vertex_positions.length/3]
      unless vi in all_border_vi
        # reindex remaining vertices
        index_map[vi] = new_index+=1
        # copy over vertices and normals
        vi3 = vi*3
        model_data.vertex_positions.push vp for vp in mesh.vertex_positions[vi3..vi3+2]
        # ensure normals face outwards
        if should_reverse
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