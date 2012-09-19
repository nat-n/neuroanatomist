class User < ActiveRecord::Base
  has_many :versions
  validate :validate_alias
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  scope :admins, where(:admin => true)
  
  def next_data_count
    self.data_count += 1
    self.save
    self.data_count
  end
  
  def user_alias
    attributes["alias"]
  end
  
  private
    def validate_alias
      return true unless user_alias
      u_alias = user_alias.strip.squeeze(' ')
      errors.add :alias, "Your alias may not be longer 10 characters." if u_alias.length > 10
      errors.add :alias, "Your alias must be at least 3 characters long." if u_alias.length < 3
      errors.add :alias, "You cannot use this alias." if ["anon.", "anon"].include?(u_alias) or 
        ["shit", "fuck", "cunt", "admin", "cock", "crap", "suck"].include? u_alias.downcase and not admin
      existing = User.where(alias: u_alias).first
      errors.add :alias, "This alias is already in use." if existing and not existing.id == id
    end
end
