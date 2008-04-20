require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  # tasks to test each subsystem
  %w(browse_node cart item).each do |component|
    Rake::TestTask.new(component.to_sym) do |t|
      t.pattern = "test/**/#{component}_test.rb"
      t.verbose = true
    end  
  end
end
