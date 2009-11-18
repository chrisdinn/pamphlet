require 'test_helper'

class BaseTest < Test::Unit::TestCase
  
  def test_settings_load
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({'test_setting' => "this is a test setting"}.to_yaml)}
    assert_equal "this is a test setting", Pamphlet.settings['test_setting']
  end
  
end