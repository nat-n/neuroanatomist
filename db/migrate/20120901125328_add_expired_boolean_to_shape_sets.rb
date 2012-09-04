class AddExpiredBooleanToShapeSets < ActiveRecord::Migration
  def change
    add_column :shape_sets, :expired, :boolean, :default => false
  end
end
