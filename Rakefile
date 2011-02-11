require 'rubygems'
require 'rake'

begin
	require 'jeweler'
	Jeweler::Tasks.new do |gem|
		gem.name = "ccls-surveyor"
		gem.summary = %Q{A rails (gem) plugin to enable surveys in your application}
		gem.email = "github@jakewendt.com"
		gem.homepage = "http://github.com/ccls/surveyor"
		gem.authors = ["Brian Chamberlain", "Mark Yoon",'Jake Wendt']
		gem.add_dependency 'haml'
		# gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
	end
	Jeweler::GemcutterTasks.new

rescue LoadError
	puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

begin
	require 'spec/rake/spectask'
	Spec::Rake::SpecTask.new(:spec) do |spec|
		spec.libs << 'lib' << 'spec'
		spec.spec_files = FileList['spec/**/*_spec.rb']
	end

	Spec::Rake::SpecTask.new(:rcov) do |spec|
		spec.libs << 'lib' << 'spec'
		spec.pattern = 'spec/**/*_spec.rb'
		spec.rcov = true
	end
rescue LoadError
	puts "RSpec is not available. In order to run those tasks, you must: sudo gem install rspec"
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
	if File.exist?('VERSION.yml')
		config = YAML.load(File.read('VERSION.yml'))
		version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
	else
		version = ""
	end

	rdoc.rdoc_dir = 'rdoc'
	rdoc.title = "surveyor #{version}"
	rdoc.rdoc_files.include('README*')
	rdoc.rdoc_files.include('lib/**/*.rb')
end

