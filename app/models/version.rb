class Version < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :updated, :polymorphic => true
  
  validates_presence_of   :version_string
  attr_protected          :version_string
  
  
  validate :no_updating, :on => :update
  
  
  def self.init_for object, params
    return false unless object.versions.empty?
    new_version = Version.new(description:    (params[:description] or ""),
                              user:           (params[:user] or User.admins.first))
    new_version.version_string = Versionomy.parse((params[:version].to_s or "0.0.1")).to_s
    object.versions << new_version
    new_version.save :validate => false
  end
  
  def self.current_for object # needs testing still
    Version.where(:updated_id => object.id).sort{|a,b|a.version<=>b.version}.last
  end
  
  def version
    Versionomy.parse version_string
  end
  
  def to_s
    version_string
  end
  
  def bump size, description, user
    return nil unless is_current
    return false unless [:major,:minor,:tiny,:patch].include? size
    size = :tiny if :size == :patch
    next_version = version.bump(size)
    new_version = Version.new( description:    description,
                                  user:           user,
                                  description:    description)
    new_version.version_string = next_version.to_s
    updated.versions << new_version
    new_version.save :validate => false
    no_longer_current
  end
  
  def tiny_update description, user
    bump :minor, description, user
  end
  
  def minor_update description, user
    bump :minor, description, user
  end
  
  def major_update description, user
    bump :minor, description, user
  end
    
  private
    def no_updating
      attributes.each do |k,v|
        next if k == "id" or (k == "is_current" and v == false)
        errors.add(k, "#{k} is already set!") if self.attributes[k] and self.attributes[k] != v
      end if self.id
    end
    
    def no_longer_current
      update_attributes :is_current => false
    end
  
end
