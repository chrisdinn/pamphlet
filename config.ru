require 'rack'
require 'pamphlet'

use Pamphlet::Activator
use Pamphlet::LoginManager
run Pamphlet::Base.new