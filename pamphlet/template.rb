require 'active_record'
require 'sinatra/base'

module Pamphlet
  
  class Template < ActiveRecord::Base
    validates_presence_of :name
  end
  
  class TemplateManager < Sinatra::Base
    
    get "/template" do
      env['warden'].authenticate!
      haml "%h1 good to go"
    end
    
  end
  
end