class CreateRegionStyles < ActiveRecord::Migration
  def change
    create_table :region_styles do |t|
      t.string   :colour
      t.float    :transparency
      t.boolean  :label
      t.boolean  :orphaned
      
      t.integer :perspective_id
      t.integer :region_id

      t.timestamps
    end
  end
end
