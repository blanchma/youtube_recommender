# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
include Rake::DSL

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'resque/tasks'

Mynewtv::Application.load_tasks
