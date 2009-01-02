require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'pathname'

desc "Run unit tests."
task :default => :test

desc "Test the amazon_associate library."
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*test.rb"]
  t.verbose = true
end

spec = Gem::Specification.new do |s|
  s.name = "amazon-associates"
  s.version = "0.6.2"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.authors = ["Ben Woosley", "Dan Pickett", "Herryanto Siatono"]
  s.email = ["ben.woosley@gmail.com", "dpickett@enlightsolutions.com", "herryanto@pluitsolutions.com"]
  s.homepage = "http://github.com/Empact/amazon-associates/tree/master"
  s.platform = Gem::Platform::RUBY
  s.summary = "Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0."
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc"]
  s.require_path = "lib"
  s.autorequire = "amazon-associates"
  s.test_files = FileList["test/**/*test.rb"].to_a
  s.files = FileList["lib/**/*"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG"]
  s.add_dependency("roxml", ">= 2.3.1")
end

desc "Generate a gemspec file"
task :gemspec do
  File.open("#{spec.name}.gemspec", "w") do |f|
    f.write spec.to_ruby
  end
end

task :package=>:rdoc
task :rdoc=>:test

desc "Create a RubyGem project"
Rake::GemPackageTask.new(spec).define

desc "Install the gem"
task :install => [:package] do
  sh %{sudo gem install pkg/#{spec.name}-#{spec.version}}
end

desc "Clobber generated files"
task :clobber=>[:clobber_package, :clobber_rdoc]
