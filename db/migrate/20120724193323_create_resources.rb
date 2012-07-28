class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :title
      t.string :authors
      t.string :journal
      t.string :publication_date
      t.string :volume
      t.string :issue
      t.string :pages
      t.string :doi
      t.string :url
      t.string :abstract
      t.string :description
      
      t.integer :resource_type_id
      
      t.timestamps
    end
  end
end
