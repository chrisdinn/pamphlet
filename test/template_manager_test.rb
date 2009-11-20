require 'test_helper'

class TemplateManagerTest < Test::Unit::TestCase
  
  def app
    Pamphlet::LoginManager.new(Pamphlet::TemplateManager) 
  end
  
  context "when the admin user is logged in" do
    setup do
      Pamphlet.settings[:admin_email] = "test4@example.com"
      Pamphlet.settings[:admin_password] = Pamphlet.salted_digest("test4password")
      post "/login", :email => "test4@example.com", :password => "test4password"
    end
  
    context "when there are two templates" do
      setup do
        Pamphlet::Template.destroy_all
        Pamphlet::Template.create([{:name => "Template 1"}, {:name => "Template 2"}])
      end
    
      should "display list with both templates" do
        get "/templates"
        assert last_response.ok?
        assert last_response.body.include?("Template 1")
        assert last_response.body.include?("Template 2")
      end
      
      should "allow new template to be created" do
        get "/templates/new"
        assert last_response.ok?
        
        test_time = (Time.now - 1.day).to_s
        post "/templates", :template => { :name => "New template", :description => test_time  }
        assert 302, last_response.status
        follow_redirect!
        assert last_response.ok?
        assert last_response.body.include?(test_time)
      end
      
      should "allow templates to be edited" do
        template = Pamphlet::Template.first
        get "/templates/#{template.id}/edit"
        assert last_response.ok?
        assert last_response.body.include?(template.name)
        
        test_time = Time.now.to_s
        put "/templates/#{template.id}", :template => { :description => test_time }
        assert 302, last_response.status
        follow_redirect!
        assert last_response.ok?
        assert last_response.body.include?(test_time)
      end
    end
  end
  
  context "when no user is logged in" do
    
    should "not show the templates list" do
      get "/templates"
      assert_equal 401, last_response.status
    end
  end
    
end