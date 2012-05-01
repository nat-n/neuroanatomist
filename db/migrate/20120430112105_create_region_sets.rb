class CreateRegionSets < ActiveRecord::Migration
  def change
    create_table :region_sets do |t|
      t.string    :name
      t.string    :description
      t.timestamps
    end
  end
end
