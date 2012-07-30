class NamePerspectives < ActiveRecord::Migration
  def up
    add_column :perspectives, :name, :string
  end

  def down
    remove_column :perspectives, :name
  end
end
