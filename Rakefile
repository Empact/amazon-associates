require 'rake'
require 'rake/testtask'
require 'pathname'

desc "Run unit tests."
task :default => :test

desc "Test the amazon_associate library."
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*test.rb"]
  t.verbose = true
  t.warning = true
end
