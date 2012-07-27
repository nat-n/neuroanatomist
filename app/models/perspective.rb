class Perspective < ActiveRecord::Base
  belongs_to  :region_set
  has_many    :region_styles
  has_many    :regions, :through => :region_styles

end
