require 'sinatra/base'

module Pamphlet
  #
  # Settings
  # 
  # Make settings available as a convenient hash-like object
  # 
  class Settings < Hash
    
    @@private_settings = [:activation_code_digest, :admin_email, :admin_password, :email_activation_code_digest, :test_time]
    
    def initialize(settings_file)
      super
      @settings_file = settings_file
      reload!
    end
    
    def self.load(settings_file)
      new(settings_file)
    end
    
    def reload!
      replace(load_from_file)
    end
    
    def clear
      super
      write_to_file
    end
    
    def []=(setting, value)
      self.store(setting, value)
      write_to_file
    end
    
    def update_settings(new_settings)
      new_settings.each do |setting, value|
        self[setting.to_sym] = value
      end
      write_to_file
    end
    
    def editable
      self.reject { |setting, value| @@private_settings.include?(setting) }
    end
    
    def set_activation_code(activation_code)
      self.store( :activation_code_digest, Pamphlet.salted_digest(activation_code) )
      write_to_file
    end
    
    def activation_code_valid?(activation_code)
      Pamphlet.salted_digest(activation_code) == self[:activation_code_digest]
    end
    
    def set_admin_email_activation_code(admin_email)
      self.store( :email_activation_code_digest, Pamphlet.salted_digest(admin_email) )
      self.store( :admin_email, admin_email)
      write_to_file
    end
    
    def admin_email_activation_code_valid?(activation_code)
      Pamphlet.salted_digest(activation_code) == self[:email_activation_code_digest]
    end
    
    private
    
    def load_from_file
      File.exist?(@settings_file) ? YAML.load(File.read(@settings_file)).to_hash : {}
    end
    
    def write_to_file
      File.open(@settings_file, 'w') {|f| f.write(self.to_yaml) }
    end
          
  end
  
  # Simple sinatra app acts as controller for settings management
  class SettingsManager < Sinatra::Base
    
    get "/settings/edit" do
      env['warden'].authenticate!
      haml :settings
    end
    
    post "/settings/?" do
      env['warden'].authenticate!
      Pamphlet.settings.update_settings(params[:settings])
      redirect "/settings/edit"
    end
    
    get "/settings/?" do
      halt 404, "page not found"
    end
    
    helpers do
      def humanize_setting_name(name)
        name.to_s.gsub("_", ' ')
      end
    end
    
  end
    
end