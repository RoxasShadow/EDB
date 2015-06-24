#! /usr/bin/env ruby
require 'rake'

task default: [ :build, :install ]

task :build do
  sh 'gem build edb.gemspec'
end

task :install do
  sh 'gem install *.gem'
end
