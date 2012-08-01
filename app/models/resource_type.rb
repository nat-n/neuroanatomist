class ResourceType < ActiveRecord::Base
  has_many :resources
  validates_uniqueness_of :name
end
