class CreateRegionDefinitions < ActiveRecord::Migration
  def change
    create_table :region_definitions do |t|
      t.references  :region
      t.references  :shape_set
      t.boolean     :orphaned
      t.string      :notes
      t.timestamps
    end
  end
end
