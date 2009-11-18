require 'rack'
require 'pamphlet'

app = lambda { |env| [200, {'Content-Type' => 'text/html'}, "Damn this pamphlet is interesting."]}

use Pamphlet::Activator
run app