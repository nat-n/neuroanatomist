class Relation < ActiveRecord::Base
  belongs_to  :subject_type, :class_name => "Type", :foreign_key => 'subject_type_id'
  belongs_to  :object_type, :class_name => "Type", :foreign_key => 'object_type_id'
  has_many    :facts
end
