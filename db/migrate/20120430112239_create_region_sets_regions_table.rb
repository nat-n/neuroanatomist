class CreateRegionSetsRegionsTable < ActiveRecord::Migration
  def up
    create_table :region_sets_regions, :id => false do |t|
      t.integer :region_set_id, :region_id
    end
  end

  def down
    drop_table :region_sets_regions
  end
end
