class Mesh < ActiveRecord::Base
  belongs_to  :back_shape, :class_name => "Shape", :foreign_key => 'back_shape_id'
  belongs_to  :front_shape, :class_name => "Shape", :foreign_key => 'front_shape_id'
  after_save  :save_mesh_data
    
  def data_path
    "#{front_shape.shape_set.data_path}/#{mesh_data_id}"
  end
  
  def name
    self.mesh_data_id
  end
  
  def vertices form=:json
    case form
    when :json  
      "[#{File.open("#{data_path}/vertex_positions", "r").read}]"
    when :data
      File.open("#{data_path}/vertex_positions", "r").read.split(/,\s*/).map{|x|x.to_f}
    end
  end
  
  def normals form=:json
    case form
    when :json  
      "[#{File.open("#{data_path}/vertex_normals", "r").read}]"
    when :data
      File.open("#{data_path}/vertex_normals", "r").read.split(/,\s*/).map{|x|x.to_f}
    end
  end
  
  def faces form=:json
    case form
    when :json  
      "[#{File.open("#{data_path}/faces", "r").read}]"
    when :data
      File.open("#{data_path}/faces", "r").read.split(/,\s*/).map{|x|x.to_i}
    end
  end
  
  def borders form=:json
    case form
    when :json
      File.open("#{data_path}/borders", "r").read
    when :data
      ActiveSupport::JSON.decode File.open("#{data_path}/borders", "r").read
    end
  end
  
  def validate_and_save mesh_data, shape_set
    # should have some form of validation of mesh data, i.e. catch errors before they become webGL errors
    
    @mesh_data = mesh_data
    @shape_set = shape_set
        
    @new_params = { :mesh_data_id => @mesh_data["name"] }
    
    shape_ids = @mesh_data["name"].split("-").map { |x| x.to_i }
    @new_params[:back_shape_id] = Shape.where("shape_set_id = #{@shape_set.id} and volume_value = #{shape_ids[0]}").first.id unless shape_ids[0] == 0
    @new_params[:front_shape_id] = Shape.where("shape_set_id = #{@shape_set.id} and volume_value = #{shape_ids[1]}").first.id
     
    mesh_data = {}    
    mesh_data[:vertex_positions] = @mesh_data["vertex_positions"].join(",")
    mesh_data[:vertex_normals]   = @mesh_data["vertex_normals"].join(",")
    mesh_data[:faces]            = @mesh_data["faces"].join(",")
    mesh_data[:borders]          = JSON::dump(@mesh_data["borders"])
    @mesh_data = mesh_data
    
    datasize = 0
    @mesh_data.each { |key,data| datasize += data.to_s.size }
    @new_params[:datasize] = datasize
    
    self.update_attributes @new_params
  end
  
  def save_mesh_data
    @mesh_data.each do |feild, data|
      mesh_dir = "#{@shape_set.data_path}/#{self.mesh_data_id}"
      data_file = "#{mesh_dir}/#{feild.to_s}"
      FileUtils.mkdir mesh_dir unless File.directory? mesh_dir
      File.open(data_file, 'w').write data
    end
  end
  
end
