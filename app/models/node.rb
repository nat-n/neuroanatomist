class Node < ActiveRecord::Base
  belongs_to :thing
  has_many  :subsections, :class_name => 'Section', :foreign_key => 'article_id', :dependent => :destroy
  has_many  :subtopics, :class_name => 'Section', :foreign_key => 'topic_id', :dependent => :destroy
  has_one   :bibliography, :as => :referencable
  has_one   :perspective
  has_one   :tag
  validates_uniqueness_of :name
  validates_presence_of :name, :tag
  
  
  def self.find_by_name node_name
    Node.where(:name => node_name).first
  end
  
  def self.find_or_create node_name
    Node.find_by_name(node_name) or Node.create(:name => node_name, :tag => Tag.find_or_create(node_name))
  end
  
end
