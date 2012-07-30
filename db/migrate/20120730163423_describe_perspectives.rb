class DescribePerspectives < ActiveRecord::Migration
  def up
    add_column :perspectives, :description, :string
  end

  def down
    remove_column :perspectives, :description
  end
end
