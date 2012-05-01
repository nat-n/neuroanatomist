class ShapeSet < ActiveRecord::Base
  has_many    :region_definitions
  has_many    :regions, :through => :region_definitions
  has_many    :shapes, :dependent => :destroy
  has_many    :meshes, :through => :shapes, :source => :low_meshes
  validates   :subject, :presence => true
  validates   :version, :presence => true
  validate    :validate_version

  
  def data_path
    # should sanitise subject to make sure they're path friendly !!! ***
    "#{Rails.root}/shape_sets/#{self.subject}/#{self.version}"
  end
  
  def name
    "#{subject} - #{version}"
  end
  
  
  def validate_and_save shape_data

    # validates that the uploaded datafile is well formed and well typed but not that its contents are valid (e.g. valid indices)
    unless shape_data and shape_data.tempfile
      errors.add(:shape_data_file, ": upload required") 
    end
    return false unless errors.messages.empty?
    
    @shape_data = ActiveSupport::JSON.decode(shape_data.read) rescue errors.add(:shape_data_file, 'data file is not valid JSON')
    return false unless errors.messages.empty?
    
    errors.add(:shape_data_file, 'missing labels data') unless @shape_data.has_key? "labels"
    errors.add(:shape_data_file, 'missing meshes data') unless @shape_data.has_key? "meshes"
    errors.add(:shape_data_file, 'labels must be unique') unless @shape_data["labels"].values.uniq.size == @shape_data["labels"].values.size
    
    return false unless errors.messages.empty?
    
    broken = false
    @shape_data["meshes"].each do |mesh_data|
      mesh_id = mesh_data["name"].split("-").map { |x| x.to_i }
      unless mesh_id.uniq.join("-") == mesh_data["name"] and mesh_id.size == 2
        errors.add(:shape_data_file, "data file includes an invalid mesh id (#{mesh_data['name']})")
      end
      
      mesh_data["vertex_positions"].each do |f|
        unless f.class == Float
          errors.add(:shape_data_file, "data file includes invalid vertex_positions data in (#{mesh_data["name"]})")
          break
        end
        break if broken
      end
      unless mesh_data["vertex_positions"].size % 3 == 0
        errors.add(:shape_data_file, "data file includes invalid vertex_positions data in (#{mesh_data["name"]})")
        break
      end
      
      broken = false
      mesh_data["vertex_normals"].each do |f|
        unless f.class == Float
          errors.add(:shape_data_file, "data file includes invalid vertex_normals data in (#{mesh_data["name"]})")
          break
        end
        break if broken
      end
      unless mesh_data["vertex_normals"].size == mesh_data["vertex_positions"].size
        errors.add(:shape_data_file, "data file includes invalid vertex_normals data in (#{mesh_data["name"]})")
        break
      end
      
      broken = false
      mesh_data["faces"].each do |f|
        unless f.class == Fixnum
          errors.add(:shape_data_file, "data file includes invalid faces data in (#{mesh_data["name"]})")
          break
        end
        break if broken
      end
      unless mesh_data["faces"].size % 3 == 0
        errors.add(:shape_data_file, "data file includes invalid faces data in (#{mesh_data["name"]})")
        break
      end
      
      broken = false
      mesh_data["borders"].each do |border_id, border_indices|
        unless border_id.to_i.to_s == border_id
          errors.add(:shape_data_file, "data file includes invalid borders data in (#{mesh_data["name"]})")
          break
          broken = true
        end
        break if broken
        border_indices.each do |i|
          unless i.class == Fixnum
            errors.add(:shape_data_file, "data file includes invalid borders data in (#{mesh_data["name"]})")
            broken = true
            break
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
    FileUtils.mkdir_p data_path unless File.directory? data_path
    
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
  
  
  private
    def validate_version
      begin
        current_version = Versionomy.parse version 
      rescue 
        errors.add(:version, ': Invalid version number')
        return
      end
      previous_versions = ShapeSet.where("subject == '#{subject}'").select(:version).map {|v| Versionomy.parse v.version }
      if previous_versions.max and not current_version > previous_versions.max
        errors.add(:version, "Version number must be higher than previous highest for this subject (#{previous_versions.max})")
      end
    end
  
end
