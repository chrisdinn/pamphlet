# Define user serialization
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

# Define login strategies. Just the admin user from the settings file for now.
Warden::Strategies.add(:settings_file) do
  def valid?
    params["email"]==Pamphlet.settings[:admin_email]
  end

  def authenticate!
    a = Pamphlet::AdminUser.authenticate(params["email"], params["password"])
    a.nil? ? fail!("Could not log in") : success!(a)
  end
end


module Pamphlet
  
  class LoginManager < Sinatra::Base

    use Rack::Session::Cookie
    use Warden::Manager do |manager|
        manager.default_strategies :settings_file
        manager.failure_app = LoginManager #lambda { |env| [401, {'Content-Type' => 'text/html'}, "Login failed. You don't belong here. I hope you realize what you've done. We'll find you."]}
    end 
    
    get '/unauthenticated/?' do
      redirect '/login'
    end

    get '/login/?' do
      haml :login
    end

    post '/login/?' do
      env['warden'].authenticate!
      redirect "/edit"
    end

    get '/logout/?' do
      env['warden'].logout
      redirect '/'
    end
  end
  
end