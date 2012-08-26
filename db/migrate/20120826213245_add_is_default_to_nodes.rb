class AddIsDefaultToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_default, :boolean, :default => false
  end
end
