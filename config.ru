require 'rack'
require 'pamphlet'

use Pamphlet::Activator
use Pamphlet::LoginManager
use Pamphlet::SettingsManager
run Pamphlet::Base.new