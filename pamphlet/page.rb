require 'active_record'
require 'sinatra/base'

module Pamphlet
  
  class Page < ActiveRecord::Base    
    belongs_to :template
    validates_presence_of :template
    
    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false
  end
  
  class PageManager < Sinatra::Base
    before do
      env['warden'].authenticate!
    end
    
    get "/pages/?" do
      @pages = Page.all
      haml :pages
    end
    
    get "/pages/new" do
      @templates = Template.all
      @page = Page.new
      haml :page
    end
    
    post "/pages/?" do
      @templates = Template.all
      @page = Page.create!(params[:page])
      redirect "/pages/#{@page.id}/edit"
    end
    
    get "/pages/:id/edit" do
      @templates = Template.all
      @page = Page.find_by_id params[:id]
      halt 404, "Page not found" unless @page
      haml :page
    end
    
    put "/pages/:id/?" do
      @page = Page.find_by_id params[:id]
      halt 404, "Page not found" unless @page
      @page.update_attributes!(params[:page])
      redirect "/pages/#{@page.id}/edit"
    end
    
  end
  
end