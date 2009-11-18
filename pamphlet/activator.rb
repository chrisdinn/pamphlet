require "digest/sha2"
require 'sinatra/base'
require 'pamphlet/activation_check'
require 'mail'


module Pamphlet
  #
  # Extremely simple Sinatra app for handling application activation
  # 
  ACTIVATION_URL = "/activate"
  ACTIVATION_FILE = "activated"
  ACTIVATION_SALT = "d0hnt-h8"
  
  Mail.defaults do
    smtp 'outbox.allstream.net', 25
  end
  
  def self.activated?
    File.exist?(ACTIVATION_FILE)
  end
  
  def self.activate(activation_code="")
    File.open(Pamphlet::ACTIVATION_FILE, 'w') { |f| f.write(activation_code) }
  end
  
  class Activator < Sinatra::Base
  
    use Pamphlet::ActivationCheck
    
    get Pamphlet::ACTIVATION_URL do
      if Pamphlet.activated?
        halt 401, "This application has already been activated"
      else
        haml :activate
      end
    end
    
    post Pamphlet::ACTIVATION_URL do
      if Pamphlet.activated?
        halt 401, "This application has already been activated"
      else
        if params[:activation_code] && (Digest::SHA256.hexdigest(params[:activation_code] + Pamphlet::ACTIVATION_SALT)==Pamphlet.settings['activation_code_digest'])
          if (params[:email]&&params[:email_confirmation]) && params[:email]==params[:email_confirmation]
            @email = params[:email]
            @email_activation_code = Pamphlet.settings['email_activation_code'] || Digest::SHA256.hexdigest(@email + Pamphlet::ACTIVATION_SALT)
            File.open(Pamphlet::SETTINGS_FILE, 'a') { |f| f.write("email_activation_code: #{@email_activation_code}")}
            # Send activation email
            mail = Mail.new({ :to => @email, :from => 'do_not_reply@chrisdinn.ca', :subject => 'Activate your new website', :body => @email_activation_code })
            mail.deliver!
            haml :admin_email_sent
          else
            haml :admin_email_form
          end
     #   Pamphlet.activate(params[:activation_code])
      #  redirect "/"
      #else
      #  halt 422, "Sorry, activation invalid." # Unprocessable entity
        end
      end
    end
    
    helpers do
      
    end
    
  end
  
end