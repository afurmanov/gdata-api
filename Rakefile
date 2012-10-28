require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def test_files
  test_dir = "test"
  FileList[Dir.glob("#{test_dir}/*_test.rb")]  
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList[*test_files]
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "gdata-api"
    s.summary = "Google Data API expressed in Ruby"
    s.email = "aleksandr.furmanov@gmail.com"
    s.homepage = "http://github.com/afurmanov/gdata-api"
    s.authors = ["Fedor Kocherga"]
    s.test_files = test_files
    s.add_dependency 'nokogiri', '>= 1.3.3'
    s.add_dependency 'tagged_logger'
    s.add_development_dependency 'thoughtbot-shoulda'
    s.add_development_dependency 'jeweler'
    s.add_development_dependency 'redis'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
