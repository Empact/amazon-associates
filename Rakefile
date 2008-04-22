require 'rake'
require 'rake/testtask'
require 'pathname'

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end

namespace :test do
  # tasks to test each subsystem
  def test_types
    Pathname.new("test/amazon").children.map {|c| /(.+)\_test\.rb/.match(c.basename.to_s)[1] }
  end

  test_types.each do |type|
    Rake::TestTask.new(type.to_sym) do |t|
      t.pattern = "test/**/#{type}_test.rb"
      t.verbose = true
      t.warning = true
    end
  end
end
