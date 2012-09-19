class AddQuizDataAndActivatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_stats, :string
    add_column :users, :activated,  :boolean, :default => false
  end
end
