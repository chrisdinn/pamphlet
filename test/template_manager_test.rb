require 'test_helper'

class TemplateManagerTest < Test::Unit::TestCase
  
  def app
    Pamphlet::LoginManager.new(Pamphlet::TemplateManager) 
  end
  
  context "when you're logged in" do
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
    
      should "display list with both template" do
        get "/templates"
        assert last_response.ok?
        assert last_response.body.include?("Template 1")
        assert last_response.body.include?("Template 2")
      end
    end
  end
  
  context "when you're not logged in" do
    
    should "not show the templates list" do
      get "/templates"
      assert_equal 401, last_response.status
    end
  end
    
end