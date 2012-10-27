require 'rubygems'

require 'mongo'
module GData
  module Atom
    class Category
    end
  end
end

GData::Atom::Category

$db = Mongo::Connection.new.db("mongo_test")

def test1()
  entries = $db.collection('entries')
  entries.drop
  entries.insert( "category" => GData::Atom::Category.to_s, "update" => DateTime.new.to_s) 
  entries.find.each { |e| p e}
end

def test2()
  gsessions = $db.collection('gsessions')
  gsessions.drop
  user_id = "aretry.school.test@gmail.com"
  {"$set" => {"i" => 2}}
  gsessions.update( { "user_id" => user_id}, { "$set" => { "user_id" => user_id, "Auth" => "token" }}, :upsert => true)
  gsessions.find.each { |e| p e}
  p "---------------"
  gsessions.update( { "user_id" => user_id}, { "$set" => { "user_id" => user_id, "gsession_id" => "gsession_id" }}, :upsert => true)
  gsessions.find.each { |e| p e}
end

test2()

# {"category"=>[{:class=>GData::Atom::Category, "term"=>"http://schemas.google.com/g/2005#event", "scheme"=>"http://sch
# emas.google.com/g/2005#kind"}], "etag"=>"\"EEwIQQFBfSp7IGA6WhJT\"", "link_to_self"=>"http://www.google.com/calendar/f
# eeds/artery.school.test%40gmail.com/private/full/eqhoc9gto6khoj1fbiuo59u51k_20100126T070000Z", :class=>GData::Event, 
# "author"=>[{"name"=>"artery.school.test@gmail.com", :class=>GData::Atom::Author, "email"=>"artery.school.test@gmail.c
# om"}], "title"=>"Oil Painting", "published"=>"0001-12-31T00:00:00.000Z", "id"=>"http://www.google.com/calendar/feeds/
# artery.school.test%40gmail.com/events/eqhoc9gto6khoj1fbiuo59u51k_20100126T070000Z", "when"=>[{:class=>GData::When, "s
# tartTime"=>#<DateTime: 58925347/24,1/8,2299161>, "endTime"=>#<DateTime: 14731337/6,1/8,2299161>}], "who"=>[{:class=>G
# Data::Who, "rel"=>"http://schemas.google.com/g/2005#event.organizer", "valueString"=>"artery.school.test@gmail.com", 
# "email"=>"artery.school.test@gmail.com"}], "link"=>[{"href"=>"http://www.google.com/calendar/event?eid=ZXFob2M5Z3RvNm
# tob2oxZmJpdW81OXU1MWtfMjAxMDAxMjZUMDcwMDAwWiBhcnRlcnkuc2Nob29sLnRlc3RAbQ", :class=>GData::Atom::Link, "rel"=>"alterna
# te"}, {"href"=>"http://www.google.com/calendar/feeds/artery.school.test%40gmail.com/private/full/eqhoc9gto6khoj1fbiuo
# 59u51k_20100126T070000Z", :class=>GData::Atom::Link, "rel"=>"self"}, {"href"=>"http://www.google.com/calendar/feeds/a
# rtery.school.test%40gmail.com/private/full/eqhoc9gto6khoj1fbiuo59u51k_20100126T070000Z", :class=>GData::Atom::Link, "
# rel"=>"edit"}], "where"=>[{:class=>GData::Where}], "updated"=>#<DateTime: 70710401101/28800,0,2299161>}             
