class Version < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :updated, :polymorphic => true
  
  validates_presence_of   :version_string
  attr_protected          :version_string
  
  
  validate :no_updating, :on => :update
  
  
  def self.init_for object, params
    return false unless object.versions.empty?
    new_version = Version.new(description:    (params[:description] or ""),
                              contents:       (params[:contents] or nil),
                              user:           (params[:user] or User.admins.first))
    new_version.version_string = Versionomy.parse((params[:version].to_s or "0.0.1")).to_s
    object.versions << new_version
    new_version.save :validate => false
    new_version
  end
  
  def self.current_for object # needs testing still
    Version.where(:updated_id => object.id).sort{|a,b|a.version<=>b.version}.last
  end
  
  def version
    Versionomy.parse version_string
  end
  
  def previous
    # finds the next most recent version assigned to the same updated object, won't neccessarily work for shape_sets
    ordered = updated.versions.sort{|a,b| b.version <=> a.version}
    if (i = ordered.index(self)) >= 0
      return ordered[i+1]
    end
    nil
  end
  
  def to_s
    version_string
  end
  
  def bump size, description_or_params, user
    return nil unless is_current and (size = Version.do size)
    next_version = version.bump(size)
    if description_or_params.is_a? Hash
      description = (description_or_params[:description] or "")
      contents = (description_or_params[:contents] or "")
    else
      description = description_or_params
      contents = nil
    end
    new_version = Version.new(  description:  description,
                                user:         user,
                                contents:     contents)
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
  
  def self.do size
    size = size.to_sym
    return false unless [:major,:minor,:tiny,:patch].include? size
    size = :tiny if :size == :patch
    size
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
