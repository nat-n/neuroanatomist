class AddAttachmentMeshdataToMesh < ActiveRecord::Migration
  def self.up
    add_column :meshes, :meshdata_id, :string
    add_column :meshes, :meshdata_file_name, :string
    add_column :meshes, :meshdata_content_type, :string
    add_column :meshes, :meshdata_file_size, :integer
    add_column :meshes, :meshdata_updated_at, :datetime
  end

  def self.down
    remove_column :meshes, :meshdata_id
    remove_column :meshes, :meshdata_file_name
    remove_column :meshes, :meshdata_content_type
    remove_column :meshes, :meshdata_file_size
    remove_column :meshes, :meshdata_updated_at
  end
end
