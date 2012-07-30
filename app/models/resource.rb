class Resource < ActiveRecord::Base
  belongs_to :resource_type
  has_and_belongs_to_many :bibliographies
  has_and_belongs_to_many :tags
  has_many :ratings, :as => :taggable
  validates_presence_of :resource_type, :title
  
  def type
    :resource_type
  end
  
end
