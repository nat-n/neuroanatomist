class AddDataIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data_count, :integer, :default => 0
    add_column :users, :group,      :string,  :default => "none"
  end
end
