class AddDataIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data_count, :integer, :default => 0
  end
end
