class Node < ActiveRecord::Base
  belongs_to :thing
  has_many  :subsections, :class_name => 'Section', :foreign_key => 'article_id', :dependent => :destroy
  has_many  :subtopics, :class_name => 'Section', :foreign_key => 'topic_id', :dependent => :destroy
  has_many :versions,           :as         => :updated,            :dependent => :destroy
  has_one   :bibliography, :as => :referencable
  has_one   :perspective
  has_one   :tag
  validates_uniqueness_of :name
  validates_presence_of :name, :tag
  
  include VersioningHelper
  
  def name
    attribute(:name).gsub(/_+/, " ")
  end
  
  def wikipedia_uri *args
    thing.wikipedia_uri *args if thing
  end
  
  def dbpedia_uri *args
    thing.dbpedia_uri *args if thing
  end

  def neurolex_uri *args
    thing.neurolex_uri *args if thing
  end

  def scholarpedia_uri *args
    thing.scholarpedia_uri *args if thing
  end
  
  def self.find_by_name node_name
    Node.where(:name => node_name).first
  end
  
  def self.find_or_create node_name
    Node.find_by_name(node_name) or Node.create(:name => node_name, :tag => Tag.find_or_create(node_name))
  end
  
  def self.default
    defaults = Node.where(:is_default => true)
    case defaults.size
    when 1
      return defaults.first
    when 0
      return Node.last.make_default!
    else
      return defaults.first.make_default!
    end
  end
  
  def make_default!
    Node.update_all(:is_default => false)
    self.update_attribute :is_default, true
    self
  end
  
  def is_default?
    default
  end
  
end
