class CreateFacts < ActiveRecord::Migration
  def change
    create_table :facts do |t|
      t.integer   :relation_id
      t.integer   :subject_id
      t.integer   :object_id
      
      t.timestamps
    end
  end
end
