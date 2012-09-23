class VCachesSecurity < ActiveRecord::Migration
  def change
    add_column    :v_caches,  :request_hash,  :string
    add_column    :v_caches,  :response_hash, :string
    remove_column :v_caches,  :cache_id
  end
end
