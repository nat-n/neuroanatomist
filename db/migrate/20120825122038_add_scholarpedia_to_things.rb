class AddScholarpediaToThings < ActiveRecord::Migration
  def change
    add_column :things, :scholarpedia_article, :string
  end
end
