require "digest/sha2"
require 'sinatra/base'
require 'pamphlet/activation_check'

module Pamphlet
  #
  # Extremely simple Sinatra app for handling application activation
  # 
  ACTIVATION_URL = "/activate"
  ACTIVATION_FILE = "activated"
  ACTIVATION_SALT = "d0hnt-h8"
  
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
      elsif params[:activation_code] && Digest::SHA256.hexdigest(params[:activation_code] + Pamphlet::ACTIVATION_SALT)==Pamphlet.settings['activation_code_digest']
        Pamphlet.activate(params[:activation_code])
        redirect "/"
      else
        halt 422, "Sorry, activation invalid." # Unprocessable entity
      end
    end
    
    helpers do
      
    end
    
  end
  
end