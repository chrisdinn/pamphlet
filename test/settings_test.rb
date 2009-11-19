require 'test_helper'

class SettingsTest < Test::Unit::TestCase
  
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
      assert_equal @settings[:test_time], time
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
  
end