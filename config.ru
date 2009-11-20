require 'rack'
require 'pamphlet'

use Pamphlet::Activator
use Pamphlet::LoginManager
use Pamphlet::SettingsManager
use Pamphlet::TemplateManager
run Pamphlet::Base.new