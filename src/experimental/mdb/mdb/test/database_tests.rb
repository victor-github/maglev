# MiniTest suite for the MDB::Database
puts "================== require rubygems =======Maglev.persistent? #{Maglev.persistent?}============="
require 'rubygems'

puts "================== require minitest/spec ==Maglev.persistent? #{Maglev.persistent?}=================="
require 'minitest/spec'

puts "================== require mdb/database ===Maglev.persistent? #{Maglev.persistent?}================="
require 'mdb/database'

puts "================== require mdb/server ===Maglev.persistent? #{Maglev.persistent?}================="
require 'mdb/server'

puts "================== require helpers ====Maglev.persistent? #{Maglev.persistent?}================"
require 'helpers'

puts "================== DONE ===Maglev.persistent? #{Maglev.persistent?}================="
MiniTest::Unit.autorun

DB_NAME = MDB::Test.db_name 'database_tests'

describe MDB::Database do
  before do
    MDB::Test.delete_test_dbs
    MDB::Server.create(DB_NAME, ViewClass)
    @db = MDB::Server[DB_NAME]
  end

  it 'execute_view executes the requested view (view is symbol or string)' do
    @db.execute_view('view_42').must_equal 42
    @db.execute_view(:view_42).must_equal 42
  end

  it 'execute_view raises NoSuchView if there is no view of the given name' do
    proc { @db.execute_view(:not_a_view_name) }.must_raise MDB::Database::NoViewError
  end

  it 'set_view updates the view class' do
    @db.execute_view(:view_42).must_equal 42 # Ensure old view
    @db.set_view(ViewClass2)
    @db.execute_view(:view_42).must_equal 43 # Ensure new view
  end

  it 'adds the document to the saved documents and can get it by id' do
    my_document = Object.new
    id = @db.add(my_document)
    @db.get(id).must_equal my_document
    # TODO: need to ensure my_document is committed
  end

  it 'add calls the model callback function' do
    ViewClass.reset_count
    ViewClass.count.must_equal 0
    @db.add(Object.new)
    ViewClass.count.must_equal 1
  end
end