#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Metasploit::Credential'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)

begin
 load 'rails/tasks/engine.rake'
rescue LoadError
  puts "railties not in bundle, so can't load engine tasks."
  print_without = true
end

Bundler::GemHelper.install_tasks

#
# load rake files like a normal rails app
# @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
#

pathname = Pathname.new(__FILE__)
root = pathname.parent
rakefile_glob = root.join('lib', 'tasks', '**', '*.rake').to_path

Dir.glob(rakefile_glob) do |rakefile|
  load rakefile
end

begin
  require 'rspec/core'
rescue LoadError
  puts "rspec not in bundle, so can't set up spec tasks.  " \
       "To run specs ensure to install the development and test groups."
  print_without = true
else
  require 'rspec/core/rake_task'

  # @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
end

if print_without
  puts "Bundle currently installed '--without #{Bundler.settings.without.join(' ')}'."
  puts "To clear the without option do `bundle install --without ''` (the --without flag with an empty string) or " \
       "`rm -rf .bundle` to remove the .bundle/config manually and then `bundle install`"
end
