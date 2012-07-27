class Section < ActiveRecord::Base
  belongs_to  :node, :class_name => "Node", :foreign_key => 'topic_id'
  belongs_to  :article, :class_name => "Node", :foreign_key => 'article_id'
  has_one   :bibliography
  has_one   :perspective
  
end
