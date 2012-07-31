class AddLabelToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :label, :string
  end
end
