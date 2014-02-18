require 'yaml'

dbconfig = YAML::load(File.open(File.expand_path('..',__FILE__)+'/database.yml'))  
ActiveRecord::Base.establish_connection(dbconfig) 

if dbconfig['database']==':memory:'
  $stdout = File.new( '/dev/null', 'w' )
	ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  $stdout = STDOUT
end
