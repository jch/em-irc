#!/usr/bin/env rake
require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = '--tag ~integration'
end

RSpec::Core::RakeTask.new('spec:ci') do |t|
  t.pattern = 'spec/integration/*_spec.rb'
end

task :default => :spec