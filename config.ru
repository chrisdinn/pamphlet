require 'rack'
require 'pamphlet'

use Pamphlet::Activator
use Pamphlet::LoginManager
use Pamphlet::SettingsManager
use Pamphlet::TemplateManager
use Pamphlet::PageManager
run Pamphlet::Base.new