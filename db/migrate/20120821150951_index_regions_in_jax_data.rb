class IndexRegionsInJaxData < ActiveRecord::Migration
  def change
    add_column :jax_data, :regions, :string
  end
end
