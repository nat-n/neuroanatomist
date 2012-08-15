class CreateJaxData < ActiveRecord::Migration
  def change
    create_table :jax_data do |t|
      
      t.string  :request_string

      t.string  :response_description

      t.integer :cache_id

      t.string  :destroy_key
      
      t.integer :shape_set_id
      
      t.string  :perspectives
      
      t.integer :count, :default => 0
      
      t.boolean :expired, :default => false
      
      t.timestamps
    end
    
    add_index :jax_data, :request_string, :unique => true
    add_index :jax_data, :shape_set_id
    
  end
end
