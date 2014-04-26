class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  
  after_create :reset_authentication_token!
  
  # https://github.com/plataformatec/devise/blob/master/lib/devise/models/token_authenticatable.rb
  def self.login_from_api(auth=nil, session_token=nil)
    return false unless auth || session_token
    if auth
      p auth.credentials
      user = User.find_by_email(auth.credentials[0])        #email
      if user && user.valid_password?(auth.credentials[1])  #password
        user.reset_authentication_token!
        user.reload
      end
    else
      user = where(:authentication_token => session_token).first
    end
  end
  
  def reset_authentication_token!
    self.reset_authentication_token
    self.save(:validate => false)
    self.authentication_token
  end
end
