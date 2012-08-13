class RegionDefinition < ActiveRecord::Base
  has_and_belongs_to_many :shapes
  belongs_to  :shape_set
  belongs_to  :region
  validates_presence_of :shape_set, :region
  validate    :only_one_definition_per_region, :message => "A region may be defined only once per shape set"
  
  def self.all_definitions_for_shape_set shape_set
    RegionDefinition.where("shape_set_id = ? and orphaned = ?", shape_set.id, false)
  end
  
  def self.orphans
    RegionDefinition.where "orphaned"
  end
  
  def label_string
    shape_set.name + "::" + shapes.map(&:label).sort.join("+")
  end
  
  def self.create_from_label_string region_id, label_string
    shape_set, shapes = label_string.split("::")
    shape_set = shape_set.split(" - ")
    shape_set = ShapeSet.where("subject = ? and version = ?",shape_set[0],shape_set[1]).first
    shapes = shapes.split("+").map { |shape| Shape.where("shape_set_id = ? and label = ?", shape_set.id, shape).first }
    new_region_def = RegionDefinition.create :shape_set_id => shape_set.id, :region_id => region_id
    new_region_def.shapes << shapes
    new_region_def
  end
  
  def border_ids
    meshes.map {|m| m.borders(:data).keys }.flatten.uniq
  end
  
  def intersect? other, by=:border
    return false unless self.shape_set == other.shape_set
    case by
      when :border; own, others = self.border_ids, other.border_ids
      when :mesh;   own, others = self.meshes,     other.meshes
      when :shape;  own, others = self.shapes,     other.shapes
      else raise "Unknown intersection type: #{by}"
    end
    (own - others).size != own.size
  end
  
  def compatible_with?
    return false unless self.shape_set == other.shape_set
    !self.shape_intersect? other, :shape
  end
  
  def meshes
    # returns only meshes which are actually used (i.e. excluding internal meshes)
    self.all_meshes.reject { |mesh| ([mesh.back_shape,mesh.front_shape]-shapes).empty? }
  end
  
  def all_meshes
    self.shapes.map {|s| s.meshes }.flatten.uniq
  end
  
  def redundant_meshes
    self.all_meshes.select { |mesh| ([mesh.back_shape,mesh.front_shape]-shapes).empty? }
  end
  
  def stitched_meshes
    stitched_mesh = {:vertices => [], :normals => [], :faces => [], :borders => {}}
    meshes.each do |mesh|
      mvertices = mesh.vertices(:data)
      mnormals  = mesh.normals(:data)
      mfaces    = mesh.faces(:data)
      mborders  = mesh.borders(:data)
      mvertex_count = mvertices.size/3
      
      # determine shared borders
      shared_borders = mborders.keys.select { |bi| stitched_mesh[:borders].has_key? bi }
      all_border_vertices = mborders.to_a.map { |bi,borders| shared_borders.include?(bi) ? borders : nil }.compact.flatten
      index_map = Hash.new
      
      # reindex border vertices
      shared_borders.each do |bi|
        mborders[bi].each_with_index do |bvi,i|
          index_map[bvi] = stitched_mesh[:borders][bi][i]
        end
      end
      
      mvertex_count.times do |vi|
        next if all_border_vertices.include? vi
        # reindex remaining vertices
        index_map[vi] = stitched_mesh[:vertices].size/3
                
        # copy over vertices and normals
        vi3 = vi*3
        stitched_mesh[:vertices] += mvertices[vi3..vi3+2]
        stitched_mesh[:normals] += mnormals[vi3..vi3+2]
      end
      
      # remap and copy faces
      stitched_mesh[:faces] += mfaces.map { |fi| index_map[fi] }
      
      # remap and copy borders
      mborders.each do |bi, border|
        next if shared_borders.include? bi
        stitched_mesh[:borders][bi] = border.map { |bvi| index_map[bvi] }
      end
    end
    stitched_mesh
  end
  
  def to_obj
    @mesh = stitched_meshes
    
    obj_string = "# region: #{region.name}\n# shape_set: #{shape_set.name}\n# meshes: #{meshes.map {|m| m.name}}\n"
    
    0.upto(@mesh[:vertices].size/3-1) do |vi|
      obj_string << "v #{@mesh[:vertices][vi*3]} #{@mesh[:vertices][vi*3+1]} #{@mesh[:vertices][vi*3+2]}\n"
      obj_string << "vn #{@mesh[:normals][vi*3]} #{@mesh[:normals][vi*3+1]} #{@mesh[:normals][vi*3+2]}\n"
    end
    
    @mesh[:faces].each_slice(3) do |i1,i2,i3|
      obj_string << "f #{i1+1} #{i2+1} #{i3+1}\n"
    end
    
    obj_string
  end
  
  def only_one_definition_per_region
    existing_definitions = RegionDefinition.where("region_id = #{region.id} and shape_set_id = #{shape_set.id}")
    unless existing_definitions.empty? or (existing_definitions.size==1 and existing_definitions.first.id = id)      
      errors.add :region, "A region may be defined only once per shape set"
      return false
    end
    return true
  end
end
