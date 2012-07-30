class Tag < ActiveRecord::Base
  belongs_to :node
  has_and_belongs_to_many :resource
  has_many :ratings
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  def self.find_by_name tag_name
    Tag.where(:name => tag_name).first
  end
  
  def self.find_or_create tag_name
    Tag.find_by_name(tag_name) or Tag.create(:name => tag_name)
  end
  
end
