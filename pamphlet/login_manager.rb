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

Warden::Manager.before_failure do |env,opts|
  # Sinatra is very sensitive to the request's method.
  # Since authentication could fail on any type of method, we need
  # to set it for the failure app so it is routed to the correct block
  env['REQUEST_METHOD'] = "POST"
end


module Pamphlet
  
  class LoginManager < Sinatra::Base

    use Rack::Session::Cookie
    use Warden::Manager do |manager|
        manager.default_strategies :settings_file
        manager.failure_app = LoginManager
    end 
    
    post '/unauthenticated/?' do
      halt 401, "Login failed. Look like you're not welcome here."
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