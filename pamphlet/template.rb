require 'active_record'
require 'sinatra/base'

module Pamphlet
  
  class Template < ActiveRecord::Base
    validates_presence_of :name
  end
  
  class TemplateManager < Sinatra::Base
    
    get "/templates" do
      env['warden'].authenticate!
      @templates = Template.all
      haml :templates
    end
    
  end
  
end