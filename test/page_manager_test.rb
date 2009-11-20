require 'test_helper'

class PageManagerTest < Test::Unit::TestCase
  
  def app
    Pamphlet::LoginManager.new(Pamphlet::PageManager) 
  end
  
  context "when the admin user is logged in" do
    setup do
      Pamphlet.settings[:admin_email] = "test4@example.com"
      Pamphlet.settings[:admin_password] = Pamphlet.salted_digest("test4password")
      post "/login", :email => "test4@example.com", :password => "test4password"
    end
    
    context "when there are two pages" do
      setup do
        template = Pamphlet::Template.create({:name => "Template 1"})
        Pamphlet::Page.create([{:name => "index", :template => template}, {:name => "contact", :template => template}])
      end
    
      should "display list with both pages" do
        get "/pages"
        assert last_response.ok?
        assert last_response.body.include?("index")
        assert last_response.body.include?("contact")
      end
      
      should "allow new page to be created" do
        get "/pages/new"
        assert last_response.ok?
        
        test_time = (Time.now - 1.day).to_s
        post "/pages", :page => { :name => test_time, :template_id => Pamphlet::Template.first.id, :content => test_time  }
        assert 302, last_response.status
        follow_redirect!
        assert last_response.ok?
        assert last_response.body.include?(test_time)
      end
      
      should "allow pages to be edited" do
        page = Pamphlet::Page.first
        get "/pages/#{page.id}/edit"
        assert last_response.ok?
        assert last_response.body.include?(page.name)
        
        test_time = Time.now.to_s
        put "/pages/#{page.id}", :page => { :content => test_time, :template_id => Pamphlet::Template.first.id }
        assert 302, last_response.status
        follow_redirect!
        assert last_response.ok?
        assert last_response.body.include?(test_time)
      end
    end  
  end
  
  context "when no user is logged in" do
    
    should "not show the pages list" do
      get "/pages"
      assert_equal 401, last_response.status
    end
    
  end
  
end