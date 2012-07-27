class Resource < ActiveRecord::Base
  belongs_to :resources_type
  has_and_belongs_to_many :bibliographies
  has_and_belongs_to_many :tags
  has_many :ratings, :as => :taggable
  
end
