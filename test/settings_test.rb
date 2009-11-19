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
  
  should "allow settings to be set using hash-like syntax" do
    time = Time.now.to_s
    settings = Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE)
    settings[:test_time] = time
    settings.reload!
    assert_equal settings[:test_time], time
  end
  
  should "clear settings" do
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({:one => "two", :three => "four"}.to_yaml) }
    settings = Pamphlet::Settings.load(Pamphlet::SETTINGS_FILE)
    settings.clear
    settings.reload!
    assert_equal Hash.new, settings.to_hash
  end
  
end