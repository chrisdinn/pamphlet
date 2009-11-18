module Pamphlet
  
  #
  # A Rack middleware for checking the activation status of your Pamphlet.
  # 
  # Checks for the existence of an activation file. If it doesn't find one,
  # all requests will be redirected to the activation url.
  # 
  class ActivationCheck
    
    def initialize(app)
      @app = app
    end
    
    def call(env)
      if File.exist?(Pamphlet::ACTIVATION_FILE) || env["PATH_INFO"]==Pamphlet::ACTIVATION_URL
        @app.call(env)
      else
        [301, {"Location" => Pamphlet::ACTIVATION_URL, "Content-Type" => "text/html"}, "Redirecting to: #{Pamphlet::ACTIVATION_URL}"]
      end
    end
    
  end
  
end