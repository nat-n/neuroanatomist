class CreateVCaches < ActiveRecord::Migration
  def change
    create_table :v_caches do |t|

      t.timestamps
    end
  end
end
