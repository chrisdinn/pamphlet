require 'test_helper'

class BaseTest < Test::Unit::TestCase
  
  def test_settings_load
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({'test_setting' => "this is a test setting"}.to_yaml)}
    assert_equal "this is a test setting", Pamphlet.settings['test_setting']
  end
  
  def test_salted_digest
    digest = Pamphlet.salted_digest("testing digest")
    assert_equal Digest::SHA256.hexdigest("testing digest" + Pamphlet::ACTIVATION_SALT), digest
  end
  
  def test_activation
    File.delete(Pamphlet::ACTIVATION_FILE) if File.exist?(Pamphlet::ACTIVATION_FILE)
    Pamphlet.activate("abcd1234")
    assert File.exist?(Pamphlet::ACTIVATION_FILE)
  end
    
  def test_deactivation
    Pamphlet.activate("abcd1234")
    Pamphlet.deactivate
    assert !File.exist?(Pamphlet::ACTIVATION_FILE)
  end
  
  def test_activation_status
    Pamphlet.activate("abcd1234")
    assert Pamphlet.activated?
    Pamphlet.deactivate
    assert !Pamphlet.activated?
  end
  
end