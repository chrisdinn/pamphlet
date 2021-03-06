require 'mail'
require 'sinatra/base'

module Pamphlet
  
  SETTINGS_FILE = "settings.yml"
  ACTIVATION_URL = "/activate"
  ACTIVATION_FILE = "activated"
  ACTIVATION_SALT = "d0hnt-h8"
    
  Mail.defaults { smtp 'outbox.allstream.net', 25 }

  # All parts of Pamphlet share a single settings instance
  def self.settings
    @settings = Pamphlet::Settings.load(SETTINGS_FILE)
  end
  
  def self.salted_digest(text)
    Digest::SHA256.hexdigest(text + Pamphlet::ACTIVATION_SALT)
  end
  
  def self.activate(activation_code="")
    File.open(Pamphlet::ACTIVATION_FILE, 'w') { |f| f.write(activation_code) }
  end
  
  def self.deactivate
    File.delete(Pamphlet::ACTIVATION_FILE) if File.exist?(Pamphlet::ACTIVATION_FILE)
  end
  
  def self.activated?
    File.exist?(ACTIVATION_FILE)
  end
    
  class Base < Sinatra::Base
    get "/" do
      haml "%p Damn this pamphlet is interesting."
    end
    
    get "/edit" do
      env['warden'].authenticate!
      haml :edit
    end
    
    # The handler below, it really ties the app together.
    get "/*" do
      @page= Page.find_by_name params[:splat].first
      halt 404, "Template not found" unless @page
      @page.template.code
    end
    
  end
  
end