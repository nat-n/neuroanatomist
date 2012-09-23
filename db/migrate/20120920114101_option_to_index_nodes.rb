class OptionToIndexNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :include_in_index, :boolean, :default => true
    add_column :nodes, :word_count, :integer, :default => 0
  end
end
