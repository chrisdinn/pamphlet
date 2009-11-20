require 'rake/testtask'

Rake::TestTask.new('test') do |t|
    t.libs << 'test'
	  t.pattern = 'test/*_test.rb'
	  t.verbose = true
	  t.warning = false
end

namespace :db do
  desc "Migrate the database"
    task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

task :environment do
  require 'pamphlet'
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  'pamphlet.sqlite3.db'
end