class Node < ActiveRecord::Base
  belongs_to :thing
  has_many  :subsections, :class_name => 'Section', :foreign_key => 'article_id', :dependent => :destroy
  has_many  :subtopics, :class_name => 'Section', :foreign_key => 'topic_id', :dependent => :destroy
  has_one   :bibliography, :as => :referencable
  has_one   :perspective
  
end
