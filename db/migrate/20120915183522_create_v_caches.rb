class CreateVCaches < ActiveRecord::Migration
  def change
    create_table :v_caches, :force=>true do |t|
      t.string  :request_string
      t.string  :cache_id
                
      t.string  :destroy_key
                
      t.string  :cache_type
      t.string  :ids
                
      t.integer :count,   :default => 0
      t.boolean :expired, :default => false
      
      t.timestamps
    end
    
    #add_index :v_caches, :request_string
    #add_index :v_caches, :cache_id
  end
end