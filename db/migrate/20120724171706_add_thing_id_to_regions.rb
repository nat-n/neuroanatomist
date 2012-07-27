class AddThingIdToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :thing_id, :integer
  end
end
