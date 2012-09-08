class AddDefaultPerspectiveToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :default_perspective_id, :integer
    add_index  :regions, :default_perspective_id
  end
end
