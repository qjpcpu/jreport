# -*- coding: UTF-8 -*-
require 'bundler'
Bundler.require(:default)
require 'date'
require 'active_record'

JreportRoot=File.expand_path('..',__FILE__)

# Load db models
require JreportRoot+'/db/connection'
Dir[JreportRoot+'/models/*.rb'].each{|model| require model }
# Load config
Dir[JreportRoot+'/config/*.rb'].each{|config| require config }
# Load helpers
Dir[JreportRoot+'/helpers/*_helper.rb'].each do |hlp|
  hlp_name=File.basename(hlp)[0..-4].split('_').map{|x| x.capitalize}.join
  require hlp
  include Kernel.const_get(hlp_name) 
end
# Load collectors and controllers
Dir[JreportRoot+'/collectors/*.rb'].each{|c| require c }
Dir[JreportRoot+'/controllers/*.rb'].each{|c| require c }

