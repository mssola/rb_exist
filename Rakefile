begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  $stderr.puts 'You need to have Bundler installed in order to build this gem.'
end

gemspec = eval(File.read(Dir["*.gemspec"].first))

task :default => [:build]

desc "Validate the gemspec"
task :validate do
  gemspec.validate
end

desc "Build gem locally"
task :build => :validate do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

desc "Install gem locally"
task :install => :build do
  system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Remove generated files"
task :clean do
  FileUtils.rm_rf "pkg"
end

desc "Execute tests"
task :test do
  system 'rspec spec/spec_helper.rb'
end
