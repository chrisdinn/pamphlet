require "digest/sha2"
require 'sinatra/base'
require 'pamphlet/activation_check'

module Pamphlet
  #
  # Extremely simple Sinatra app for handling application activation
  # 
  class Activator < Sinatra::Base
  
    use Rack::MethodOverride
    use Pamphlet::ActivationCheck
    
    get Pamphlet::ACTIVATION_URL do
      if Pamphlet.activated?
        halt 401, "This application has already been activated"
      elsif params[:activation_code]
         halt 401, "Activaton code invalid" unless Pamphlet.settings.activation_code_valid?(params[:activation_code])
         haml :admin_email_form
      else
        haml :activate
      end
    end
    
    post Pamphlet::ACTIVATION_URL do
      if Pamphlet.activated?
        redirect "/"
      elsif check_email_confirmation(params[:email], params[:email_confirmation])
          Pamphlet.settings.set_admin_email_activation_code(params[:email])  
          # Send activation email
          mail = Mail.new({ :to => params[:email], :from => 'do_not_reply@chrisdinn.ca', :subject => 'Activate your new website', :body => "#{Pamphlet::ACTIVATION_URL}/#{Pamphlet.settings[:email_activation_code_digest]}/edit" })
          mail.deliver!
          haml :admin_email_sent
      else
        halt 422, "Sorry, can't accept that email address, maybe your confirmations didn't match. Hit 'back' and try again."
      end
    end
    
    get "#{Pamphlet::ACTIVATION_URL}/:email_code/edit" do
      if params[:email_code]==Pamphlet.settings[:email_activation_code_digest]
        haml :admin_password_form
      else
        halt 404, "You don't belong here. You must've followed a bad link."
      end
    end
    
    put "#{Pamphlet::ACTIVATION_URL}/:email_code/?" do
      if params[:email_code]==Pamphlet.settings[:email_activation_code_digest] && validate_new_password(params[:password], params[:password_confirmation])
        Pamphlet.settings[:admin_password] = Pamphlet.salted_digest(params[:password])
        Pamphlet.activate(Pamphlet.settings[:admin_email])
        haml :activation_success
      else
        halt 404, "You don't belong here. You must've followed a bad link."
      end
    end
    
    private
    
    def check_email_confirmation(email, confirmation)
      email && confirmation && (email==confirmation)
    end
    
    def validate_new_password(pw, pw_confirmation)
      pw && pw.length > 5 && pw==pw_confirmation
    end
    
  end
  
end