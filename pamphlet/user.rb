module Pamphlet
  
  def self.find_user(token)
    if token==AdminUser.find.persistent_token
      AdminUser.find
    else
      nil
    end
  end
  
  class AdminUser
    def initialize
      @email = Pamphlet.settings[:admin_email]
      @password_digest = Pamphlet.settings[:admin_password]
    end
    
    def self.find
      new
    end
    
    def self.authenticate(email, password)
      find if Pamphlet.settings[:admin_email]==email && Pamphlet.settings[:admin_password]==Pamphlet.salted_digest(password)
    end
    
    def persistent_token
      Pamphlet.salted_digest(@email.split('@').first + @password_digest )
    end
    
  end
  
end