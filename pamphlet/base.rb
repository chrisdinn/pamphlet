require 'mail'
require 'sinatra/base'
require 'active_record'

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
  
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  'pamphlet.sqlite3.db'
  
  class Base < Sinatra::Base
    get "/" do
      haml "%p Damn this pamphlet is interesting."
    end
    
    get "/edit" do
      env['warden'].authenticate!
      @templates = Template.all
      haml :edit
    end
    
  end
  
  class Template < ActiveRecord::Base
  end
  
end