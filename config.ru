require 'rack'
require 'pamphlet'

use Pamphlet::Activator
run Pamphlet::Base.new