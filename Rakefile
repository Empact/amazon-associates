require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |s|
  s.name = "amazon-associates"
  s.summary = "Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0."
  s.email = "ben.woosley@gmail.com"
  s.homepage = "http://github.com/Empact/amazon-associates"
  s.description = "amazon-associates offers object-oriented access to the Amazon Associates API, built on ROXML"
  s.authors = ["Ben Woosley", "Dan Pickett", "Herryanto Siatono"]
  s.add_runtime_dependency("roxml", ">= 3.1.3")
  s.add_runtime_dependency("activesupport", ">= 2.3.4")
  s.add_runtime_dependency("mislav-will_paginate")
  s.add_development_dependency("thoughtbot-shoulda")
  s.add_development_dependency("mocha")

  # s.require_path = "lib"
  # s.autorequire = "amazon-associates"
  # s.test_files = FileList["test/**/*test.rb"].to_a
  # s.files = FileList["lib/**/*"].to_a
end


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'amazon-associates'
  rdoc.options << '--line-numbers' << '--inline-source' << "--main README.rdoc"
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib' << 'spec'
  t.spec_opts << '--format profile --backtrace'
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |t|
  t.libs << 'lib' << 'spec'
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
end

task :default => :spec