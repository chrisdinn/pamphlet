require 'Haml'
require "warden"
require 'pamphlet/base'
require 'pamphlet/settings'  
require 'pamphlet/activator'
require 'pamphlet/user'
require 'pamphlet/login_manager'  
require 'pamphlet/template'
require 'pamphlet/page'


ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  'pamphlet.sqlite3.db'
