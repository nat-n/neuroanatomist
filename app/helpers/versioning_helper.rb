module VersioningHelper
  def current_version
    versions.where(:is_current => true).first or Version.init_for self, {}
  end
  
  def version
    current_version.version rescue nil
  end
  
  def flat_version
    Versionomy.parse "#{current_version.version.major}.0.0"
  end
  
  def version_bump size, description, user
    return false unless (size = Version.do size)
    current_version.bump size, description, user
  end
  
  def aggr_update size
    return false unless (size = Version.do size)
    @update_size = size if !defined?(@update_size) or @update_size == :tiny or size == :major
  end
  
  def do_versioning description, user
    version_bump @update_size, description, user if defined?(@update_size)
  end
  
  def bump_version size, description, user
    version_bump size, description, user
  end  
end
