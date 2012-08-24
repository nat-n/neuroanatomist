class Thing < ActiveRecord::Base
  belongs_to  :type
  has_one     :node
  has_one     :tag, :through => :node
  has_many    :regions
  has_many    :subject_facts, :class_name => 'Fact', :foreign_key => 'subject_id', :dependent => :destroy
  has_many    :object_facts, :class_name => 'Fact', :foreign_key => 'object_id', :dependent => :destroy
  validates_uniqueness_of :name
  validates_presence_of :name, :type
  
  def facts
    subject_facts + object_facts
  end
  
  def name
    attribute(:name).gsub(/_+/, " ")
  end
  
end