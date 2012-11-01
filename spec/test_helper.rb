require "rubygems"
require "bundler"
Bundler.setup

require 'test/unit'
require 'rspec'
require 'logger'
require 'tagged_logger'
require 'rr'
require 'mongo'
require 'nokogiri'

path = File.expand_path(File.dirname(__FILE__) + '/../lib')
$:.unshift(path) unless $:.include?(path)

require 'gdata/calendar'
require 'gdata/contacts'

$start_time = Time.now
TaggedLogger.rules do |level, tag, what|
  format { |level, tag, msg| "%5.3f %s\n" %[Time.now - $start_time, msg] }
  log_path = File.expand_path(File.dirname(__FILE__) + '/../logs')
  File.exists?(log_path) || `mkdir #{log_path}`
  debug /.*/, :to => Logger.new(open(File.join(log_path, 'all.log'), "w"))
  info /.*/, :to => Logger.new(STDOUT)
  debug /(Base|Atom|Feed|Entry|Event)/, :to => Logger.new(open(File.join(log_path, 'atom.log'),"w"))
  debug GData::Request, :to => Logger.new(open(File.join(log_path, 'request.log'),"w"))
end

GData::Cacher.init(Mongo::Connection.new.db("gdata"))

USER_ID = "artery.school.test@gmail.com"
PASSWORD = "ligovskij"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
