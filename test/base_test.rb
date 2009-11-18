require 'test_helper'

class BaseTest < Test::Unit::TestCase
  
  def test_settings_load
    activation_code_digest = Digest::SHA256.hexdigest("abcd1234" + Pamphlet::ACTIVATION_SALT)
    File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({'activation_code_digest' => activation_code_digest}.to_yaml)}
    assert_equal activation_code_digest, Pamphlet.settings['activation_code_digest']
  end
  
end