class Mesh < ActiveRecord::Base
  has_attached_file :meshdata,
                    :path => ("#{Rails.root}/mesh_data/tmp/:id").to_s

  validates_attachment :meshdata, :presence => true
  
  
  def process_new_meshdata
    new_file = "#{Rails.root}/mesh_data/tmp/#{self.id}"
    return false unless File.exists? new_file
    new_data = ActiveSupport::JSON.decode File.open(new_file, "r").read
    new_params = { meshdata_id: new_data["name"] }
    self.update_attributes new_params 
    
    data_dir = "#{Rails.root}/mesh_data/#{new_data["name"]}"
    Dir.mkdir data_dir unless File.directory? data_dir
    
    data_feilds = [:vertex_positions, :vertex_normals, :faces]
    data_feilds.each do |feild|
      data_file = data_dir + "/#{feild.to_s}"
      File.open("#{data_dir}/#{feild.to_s}", 'w').write new_data[feild.to_s].join(" ")
    end
    
    data_file = data_dir + "/#{"borders"}"
    File.open("#{data_dir}/borders", 'w').write JSON::dump(new_data["borders"])
    
    File.delete new_file
  end
  
end
