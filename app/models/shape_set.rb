class ShapeSet < ActiveRecord::Base
  has_many    :region_definitions, :dependent => :destroy
  has_many    :regions, :through => :region_definitions
  has_many    :shapes, :dependent => :destroy
  has_many    :meshes, :through => :shapes, :source => :low_meshes
  has_many    :jax_data
  has_one     :default_perspective_attr, :class_name => 'Perspective', :foreign_key => 'default_for_shape_set_id'
  validates_presence_of   :subject, :version
  #validates_uniqueness_of :name, :scope => [:subject, :version]
  validate    :validate_version
  
  def self.versions_of subject
    ShapeSet.where "subject = ?", subject
  end

  def self.newest_version_of subject
    ShapeSet.versions_of(subject).select(:version).map {|v| Versionomy.parse v.version }.max
  end
  
  def previous_version
    all_versions = ShapeSet.versions_of(self.subject).sort
    own_index = all_versions.index(version)
    if own_index
      return nil if own_index == 0
      own_index-1
    else
      ShapeSet.newest_version_of subject
    end
  end
  
  def self.default
    defaults = ShapeSet.where(:is_default => true)
    case defaults.size
    when 1
      return defaults.first
    when 0
      return ShapeSet.all.last.make_default! # what else can i DO? also fire off an admin email alert?
    else
      return defaults.first.make_default!
    end
  end
  
  def make_default!
    ShapeSet.update_all(:is_default => false)
    self.update_attribute :is_default, true
    self
  end
  
  def is_default?
    self == ShapeSet.default
  end
  
  def default_perspective
    # assumed no conflicting regions
    return default_perspective_attr if default_perspective_attr.kind_of? Perspective rescue nil
    # this is useless...
    set_of_all_defined_regions = Perspective.new :name => "dynamic_default", :default_for_shape_set_id => self.id
    set_of_all_defined_regions.include_regions RegionDefinition.all_definitions_for_shape_set(self).map {|d| d.region}
    set_of_all_defined_regions
  end
  
  def default_perspective= perspective
    update_attribute :default_perspective_attr, perspective
  end
    
  def name
    "#{subject} - #{version}"
  end
  
  def data_path
    # should sanitise subject to make sure they're path friendly !!! ***
    #"#{Rails.root}/shape_sets/#{self.subject}/#{self.version}"
    "#{self.subject}/#{self.version}"
  end
  
  def bounding_box
    bb = ShapeSet.last.attributes["bounding_box"]
    return JSON.load bb if bb
    nil
  end
  
  def center_point
    cp = ShapeSet.last.attributes["center_point"]
    return JSON.load(cp).map{|x| x.round(4)} if cp
    nil
  end
      
  def mesh_ids
    meshes.map { |mesh| mesh.id }
  end
  
  def ids_hash
    Hash[ shape_set_id: id,
      shapes: Hash[*shapes.map{|shape| [shape.volume_value, shape.id] }.flatten],
      meshes: Hash[*meshes.map{|mesh| [mesh.mesh_data_id, mesh.id] }.flatten]
    ]
  end

  def shape_names
    shapes.map { |shape| shape.name }
  end
  
  def has_definition_for? region
    regions.include? region
  end
  
  def hash_partial cascade
    hp = Hash[
      attrs: Hash[
        type:                 'shape_set',
        id:                   self.id,
        name:                 self.name,
        radius:               self.radius,
        center_point:         (self.center_point or nil),
        default_perspective:  (self.default_perspective.id or nil rescue nil)
      ]
    ]
    hp[:shapes] = self.shapes.map(&:id) if [true,:yes,:partial].include? cascade
    return hp
  end
  
  def copy_region_definitons_from older_shape_set
    """ Attempts to copy region defintions from an another shape_set
        - Ignores definitions for already defined regions
        - Assumes identical naming of shapes
        - Adds list of regions for which an equivalence couldn't be found to the notes attribute
    """
    older_shape_set.region_definitions.each do |region_definition|
      next if has_definition_for? region_definition.region
      if region_definition.orphaned
        failures ||= "\n--- failures in converting region definitions from: #{older_shape_set.name}\n"
        failures << " - couldn't region definition of: #{region_definition.id}\n"
      elsif region_definition.shapes.map { |shape|  shape_names.include? shape.name }.uniq == [true]
        new_definition = RegionDefinition.new :shape_set_id => self.id,
                                              :region_id    => region_definition.region.id,
                                              :notes        => "copied from #{older_shape_set.name}"
        region_definition.shapes.each do |shape|
          new_definition.shapes << Shape.where("label = ? and shape_set_id = ?", shape.name, self.id)
        end
        new_definition.save
      else
        failures ||= "\n--- failures in converting region definitions from: #{older_shape_set.name}\n"
        failures << " - couldn't match definition of: #{region_definition.region.label}\n"
      end
    end
    true
    self.notes << failures if defined? failures
  end
  
 def create_shape_based_perspective
    shape_regions = []
    shapes.each do |shape|
      # assumes there wouldn't be two regions of the same name!!
      existing_region = Region.where("name = ?", shape.name)[0]
      shape_regions << existing_region or Region.create(:name => shape.name, :description => "generated by #{self.name}")
      unless shape.has_definition_for(existing_region)
        existing_definition = RegionDefinition.where("region_id = ? and shape_set_id = ?", shape_regions.last.id, self.id)[0]
        new_rd = existing_definition or RegionDefinition.create :region_id => shape_regions.last.id, :shape_set_id => self.id, :orphaned => false, :notes => "generated by #{self.name}"
        shape.region_definitions << new_rd
      end
    end
    # create perspective from shape_regions
    new_perspective = Perspective.create :name => "All shapes", :description => "generated to include all shapes as individual regions"
    new_perspective.include_regions shape_regions
  end
  
  def validate_and_save shape_data
    """validates that the uploaded datafile is well formed and well typed but not that its contents are valid (e.g. valid indices)"""
    
    errors.add(:shape_data_file, ": upload required") unless shape_data and shape_data.tempfile
    return false unless errors.messages.empty?
    
    @shape_data = ActiveSupport::JSON.decode(shape_data.read) rescue errors.add(:shape_data_file, 'data file is not valid JSON')
    return false unless errors.messages.empty?
    
    errors.add(:shape_data_file, 'missing labels data') unless @shape_data.has_key? "labels"
    errors.add(:shape_data_file, 'missing meshes data') unless @shape_data.has_key? "meshes"
    errors.add(:shape_data_file, 'labels must be unique') unless @shape_data["labels"].values.uniq.size == @shape_data["labels"].values.size
    return false unless errors.messages.empty?
    @shape_data["meshes"].each do |mesh_data|
      mesh_id = mesh_data["name"].split("-").map { |x| x.to_i }
      unless mesh_id.uniq.join("-") == mesh_data["name"] and mesh_id.size == 2
        errors.add(:shape_data_file, "data file includes an invalid mesh id (#{mesh_data['name']})")
        break
      end
      
      mesh_data["vertex_positions"].each do |f|
        unless f.class == Float
          errors.add(:shape_data_file, "data file includes invalid vertex_positions data in (#{mesh_data["name"]})")
          break
        end
      end
      unless mesh_data["vertex_positions"].size % 3 == 0
        errors.add(:shape_data_file, "data file includes invalid vertex_positions data in (#{mesh_data["name"]})")
        break
      end
      
      mesh_data["vertex_normals"].each do |f|
        unless f.class == Float
          errors.add(:shape_data_file, "data file includes invalid vertex_normals data in (#{mesh_data["name"]})")
          break
        end
      end
      unless mesh_data["vertex_normals"].size == mesh_data["vertex_positions"].size
        errors.add(:shape_data_file, "data file includes invalid vertex_normals data in (#{mesh_data["name"]})")
        break
      end
      
      mesh_data["faces"].each do |f|
        unless f.class == Fixnum
          errors.add(:shape_data_file, "data file includes invalid faces data in (#{mesh_data["name"]})")
          break
        end
      end
      unless mesh_data["faces"].size % 3 == 0
        errors.add(:shape_data_file, "data file includes invalid faces data in (#{mesh_data["name"]})")
        break
      end
      
      broken = false
      mesh_data["borders"].each do |border_id, border_indices|
        unless border_id.to_i.to_s == border_id
          errors.add(:shape_data_file, "data file includes invalid borders data in (#{mesh_data["name"]})")
          broken = true
        end
        break if broken
        border_indices.each do |i|
          unless i.class == Fixnum
            errors.add(:shape_data_file, "data file includes invalid borders data in (#{mesh_data["name"]})")
            broken = true
          end
          break if broken
        end
        break if broken
      end
      break if broken
    end
    
    new_params = { data_created_at: @shape_data["timestamp"],
                   shape_count: @shape_data["labels"].size,
                   mesh_count: @shape_data["meshes"].size,
                   datasize: @shape_data["meshes"].to_s.size}

    return false unless errors.messages.empty?
    
    self.update_attributes new_params    
  end
  
  def save_shape_data    
    #FileUtils.mkdir_p data_path unless File.directory? data_path
    
    ## create some shapes
    @shape_data["labels"].each do |volume_value, label|
      new_shape = Shape.new :volume_value => volume_value, :label => label, :shape_set_id => self.id
      new_shape.save
    end
    
    @shape_data["meshes"].each do |mesh_data|
      new_mesh = Mesh.new
      new_mesh.validate_and_save mesh_data, self
    end
  end
  
  def generate_geometric_descriptions
    # calculates and stores the orthoganal bounding box, radius and center point of the shape_set
    big_number = 10^10
    ortho_bb = {xmin:big_number,xmax:-big_number,ymin:big_number,ymax:-big_number,zmin:big_number,zmax:-big_number}
    
    meshes.each do |mesh|
      mesh.vertices(:data).each_slice(3) do |x,y,z|
        if x < ortho_bb[:xmin] then ortho_bb[:xmin] = x
        elsif x > ortho_bb[:xmax] then ortho_bb[:xmax] = x end
        if y < ortho_bb[:ymin] then ortho_bb[:ymin] = y
        elsif y > ortho_bb[:ymax] then ortho_bb[:ymax] = y end
        if z < ortho_bb[:zmin] then ortho_bb[:zmin] = z
        elsif z > ortho_bb[:zmax] then ortho_bb[:zmax] = z end
      end
    end
    
    half_ranges = [(ortho_bb[:xmax]-ortho_bb[:xmin])/2, (ortho_bb[:ymax]-ortho_bb[:ymin])/2, (ortho_bb[:zmax]-ortho_bb[:zmin])/2]

    self.update_attribute :bounding_box, "#{JSON.dump(ortho_bb)}"
    self.update_attribute :radius, half_ranges.max.to_f.round(4)
    self.update_attribute :center_point, "#{JSON.dump([(ortho_bb[:xmin]+half_ranges[0]).round(4),
                                                       (ortho_bb[:xmin]+half_ranges[1]).round(4),
                                                       (ortho_bb[:xmin]+half_ranges[2]).round(4) ])}"
  end  
  
  private
    def validate_version
      begin
        current_version = Versionomy.parse version 
      rescue 
        errors.add(:version, ': Invalid version string')
        return
      end
      max_previous_version = ShapeSet.newest_version_of(subject)
      unless (current_version > max_previous_version rescue true) or self == ShapeSet.where(version: current_version.to_s).first
        errors.add(:version, "Version string must be higher than previous highest for this subject (#{max_previous_version})")
      end
    end
  
end
