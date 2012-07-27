class Type < ActiveRecord::Base
  belongs_to  :supertype, :class_name => "Type"
  has_many    :subtypes, :class_name => "Type", :foreign_key => "supertype_id"
  has_many    :things
  has_many    :subject_relations, :class_name => 'Relation', :foreign_key => 'subject_type_id', :dependent => :destroy
  has_many    :object_relations, :class_name => 'Relation', :foreign_key => 'object_type_id', :dependent => :destroy
  validates_uniqueness_of :name
  validates_presence_of :name, :supertype
  validate :not_being_set_as_root
  
  
  
  private
    def not_being_set_as_root
      errors.add(:supertype, "Only the root type called 'Thing' may be it's own supertype!") if supertype == self and not self.name == "Thing"
    end
    
end


