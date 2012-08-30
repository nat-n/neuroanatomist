module VersioningHelper
  def current_version
    versions.where(:is_current => true).first
  end
  
  def version
    current_version.version rescue nil
  end
  
  def version_bump size, description, user
    current_version.bump size, description, user
  end
  
end
