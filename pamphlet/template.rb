require 'active_record'
require 'sinatra/base'

module Pamphlet
  
  class Template < ActiveRecord::Base
    validates_presence_of :name
  end
  
  class TemplateManager < Sinatra::Base
    before do
      env['warden'].authenticate!
    end
    
    get "/templates" do
      @templates = Template.all
      haml :templates
    end
    
    get "/templates/:id/edit" do
      @template = Template.find_by_id params[:id]
      halt 404, "Template not found" unless @template
      haml :template
    end
    
    post "/templates/:id/?" do
      @template = Template.find_by_id params[:id]
      halt 404, "Template not found" unless @template
      @template.update_attributes(params[:template])
      redirect "/templates/#{@template.id}/edit"
    end    
  end
  
end