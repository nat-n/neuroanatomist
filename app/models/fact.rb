class Fact < ActiveRecord::Base
  belongs_to  :relation
  belongs_to  :subject, :class_name => "Thing", :foreign_key => 'subject_id'
  belongs_to  :object, :class_name => "Thing", :foreign_key => 'object_id'
end
