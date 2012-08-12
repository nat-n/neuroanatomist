class Type < ActiveRecord::Base
  belongs_to  :supertype, :class_name => "Type"
  has_many    :subtypes, :class_name => "Type", :foreign_key => "supertype_id"
  has_many    :things
  has_many    :subject_relations, :class_name => 'Relation', :foreign_key => 'subject_type_id', :dependent => :destroy
  has_many    :object_relations, :class_name => 'Relation', :foreign_key => 'object_type_id', :dependent => :destroy
  validates_uniqueness_of :name
  validates_presence_of :name, :supertype
  validate :valid_super_type
  
  
  private
    def valid_super_type
      if supertype == self and not self.name == "Thing"
        errors.add(:supertype, "Only the root type called 'Thing' may be it's own supertype!")
      end
      # traverse to root to make sure there is one
      traversed = []
      traversed << self.id if self.id
      current = supertype
      while true
        break if current.supertype == current # found valid root
        if traversed.include? current.supertype
          # found loop... oh no!
          errors.add(:supertype, "Big problem... inheritance loop detected! (contact the admins)")
          break
        end
        traversed << current
        current = current.supertype
      end
    end
    
end


