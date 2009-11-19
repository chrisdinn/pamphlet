#Warden::Manager.serialize_into_session{|user| user.persistant_token }
#Warden::Manager.serialize_from_session{|id| Pamphlet.find_user(id)  }

module Warden
  module Serializers
    class Session < Base
      
      def serialize(user)
        user.persistent_token
      end
      
      def deserialize(id)
        Pamphlet.find_user(id)
      end
      
    end
  end
end

module Pamphlet
  
  Warden::Strategies.add(:settings_file) do
    def valid?
      params["email"]==Pamphlet.settings[:admin_email]
    end

    def authenticate!
      a = Pamphlet::AdminUser.authenticate(params["email"], params["password"])
      a.nil? ? fail!("Could not log in") : success!(a)
    end
  end
  
  class LoginManager < Sinatra::Base

    use Rack::Session::Cookie
    use Warden::Manager do |manager|
        manager.default_strategies :settings_file
        manager.failure_app = lambda { |env| [401, {'Content-Type' => 'text/html'}, "Login failed. You don't belong here. I hope you realize what you've done. We'll find you."]}
    end # LoginManager 
    
    post '/unauthenticated/?' do
      status 401
      haml :login
    end

    get '/login/?' do
      haml :login
    end

    post '/login/?' do
      env['warden'].authenticate!
      redirect "/"
    end

    get '/logout/?' do
      env['warden'].logout
      redirect '/'
    end
  end
  
end