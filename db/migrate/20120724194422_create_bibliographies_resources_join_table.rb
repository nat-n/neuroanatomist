class CreateBibliographiesResourcesJoinTable < ActiveRecord::Migration
  def up
    create_table :bibliographies_resources, :id => false do |t|
      t.integer :bibliography_id, :resource_id
    end
  end

  def down
    drop_table :bibliographies_resources
  end
end
