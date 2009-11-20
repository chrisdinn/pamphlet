require 'test_helper'

class SettingsTest < Test::Unit::TestCase
    
  def app
    Pamphlet::LoginManager.new(Pamphlet::SettingsManager) 
  end
  
  should "not fail if no settings file exists" do
    File.delete(Pamphlet::SETTINGS_FILE) if File.exist?(Pamphlet::SETTINGS_FILE)
    assert_equal Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE), {}
  end
  
  should "load settings from YAML settings file" do
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({:one => "two", :three => "four"}.to_yaml) }
    settings = Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE)
    assert_equal "two", settings[:one]
    assert_equal "four", settings[:three]
  end
  
  should "clear settings" do
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({:one => "two", :three => "four"}.to_yaml) }
    settings = Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE)
    settings.clear
    settings.reload!
    assert_equal Hash.new, settings.to_hash
  end
    
  context "when a settings file and deactivated application exist" do
    setup do
      Pamphlet.deactivate
      @settings = Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE)
    end
    
    should "allow settings to be set using hash-like syntax" do
      time = Time.now.to_s
      @settings[:test_time] = time
      @settings.reload!
      assert_equal time, @settings[:test_time]
    end
    
    should "update settings from hash" do
      time = (Time.now + 1.day).to_s
      @settings.update_settings({:test_time => time })
      @settings.reload!
      assert_equal time, @settings[:test_time]
    end
  
    should "set the activation code" do
      @settings.set_activation_code("abcd1234")
      assert_equal @settings[:activation_code_digest], Pamphlet.salted_digest("abcd1234")
      assert_not_equal @settings[:activation_code_digest], Pamphlet.salted_digest("9876zyxw")
    end
  
    should "verify a submitted activation code" do
      @settings.set_activation_code("abcd1234")
      assert !@settings.activation_code_valid?("9876zyxw")
      assert @settings.activation_code_valid?("abcd1234")
    end
    
    should "set admin email activation code" do
      @settings.set_admin_email_activation_code("test@settingstest.com")
      assert_equal "test@settingstest.com", @settings[:admin_email]
      assert_equal Pamphlet.salted_digest("test@settingstest.com"), @settings[:email_activation_code_digest]
    end
    
    should "verify a submitted admin email activation code" do
      @settings.set_admin_email_activation_code("test@settingstest.com")
      assert !@settings.admin_email_activation_code_valid?("catch-this@imnotwhoyouwat.com")
      assert @settings.admin_email_activation_code_valid?("test@settingstest.com")
    end
    
  end
  
  context "when an activated application with a site admin exists" do
    setup do
      @admin_user = { :email => "test5@example.com", :password => "test5password" }
      Pamphlet.activate(@admin_user[:email])
      Pamphlet.settings[:admin_email] = @admin_user[:email]
      Pamphlet.settings[:admin_password] = Pamphlet.salted_digest(@admin_user[:password]) 
    end
    
    should "allow the admin user to edit and update settings" do
      post '/login', :email => @admin_user[:email], :password => @admin_user[:password]
      
      get "/settings/edit"
      assert last_response.ok?
      assert last_response.body.include?('settings')
      
      password_hash = Pamphlet.salted_digest(Time.now.to_s)
      post "/settings", :settings => { :database_username => "root", :database_password => password_hash }
      follow_redirect!
      assert last_response.ok?
      assert last_response.body.include?("root")      
      assert last_response.body.include?(password_hash)      
    end
    
    should "not allow any other users to edit settings" do
      get "/settings/edit"
      assert_equal 401, last_response.status
    end
    
    should "not display private settings on the settings page" do
      Pamphlet.settings[:test_time] = "5:00pm"
      post '/login', :email => @admin_user[:email], :password => @admin_user[:password]
      get "/settings/edit"
      
      assert last_response.ok?
      assert !last_response.body.include?("5:00pm") 
    end
    
  end
  
end