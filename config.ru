# This file is used by Rack-based servers to start the application.

#ENV['GEM_PATH'] = '/usr/local/lib/ruby/gems/1.9.1'

require ::File.expand_path('../config/environment',  __FILE__)
require 'resque/server'
run Mynewtv::Application

