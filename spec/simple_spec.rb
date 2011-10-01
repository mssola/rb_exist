#encoding: UTF-8

require 'libxml'

##
# Helper method useful to compare simple XML files.
#
# @param *LibXML::XML::Document* xml The xml file from a query.
#
# @param *String* test_name The name of the test.
#
# @param *Array* params The nodes that the XML parser should take care.
#
# @return *Boolean* true if both xml files are identical, false otherwise
def compare_xml(xml, test_name, params)
  result = false
  p = LibXML::XML::Parser.file test_name
  result_p = LibXML::XML::Parser.string xml.to_s
  doc = p.parse
  result_d = result_p.parse
  params.each do |p|
    a = doc.find("//#{p}").to_a
    b = result_d.find("//#{p}").to_a
    return false if a.size != b.size
    a.size.times { |i| return false if a[i].content != b[i].content }
  end
  true
end

##
# Generate an XML row.
#
# @param *String* tag_name The name of the tag
#
# @param *Hash* values The subnodes of the tag named "#{tag_name}".
# Each key represents the name of each tag.
#
# @return *String* A string containing a valid XML row.
def generate_xml(tag_name, values)
  xml = "<#{tag_name}>"
  values.each { |key, value| xml += "<#{key}>#{value}</#{key}>" }
  xml += "</#{tag_name}>"
end

# Let the testing begin!

describe 'SimpleSQL' do
  it 'raises an exception if some of the parameters are not properly passed' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql

    # Select
    expect{sql.select({})}.to raise_error(ArgumentError)
    expect{sql.select({ :where => 'age>20'})}.to raise_error(ArgumentError)

    # Insert
    expect{sql.insert({})}.to raise_error(ArgumentError)
    expect{sql.insert(row: 'asd')}.to raise_error(ArgumentError)
    expect{sql.insert(row: 'asd', element: 'this')}.to raise_error(ArgumentError)

    # Update
    expect{sql.update({})}.to raise_error(ArgumentError)
    expect{sql.update(where: 'age>20')}.to raise_error(ArgumentError)

    # Delete
    expect{sql.delete({})}.to raise_error(ArgumentError)
    expect{sql.delete(where: 'age>20')}.to raise_error(ArgumentError)

    db.delete 'users.xml'
  end

  it 'executes the select query correctly' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'users.xml', ['name', 'age']).should eql(true)
    sql.count.should eql('3')

    xml= sql.select(:from => 'users', :where => 'age>19')
    compare_xml(xml, base + 'users_rev.xml', ['name', 'age']).should eql(true)
    sql.count.should eql('2')

    xml = sql.select(rows: ['age'], from: 'users',
                   where: "name/text()!='Pedobear'",
                   order_by: 'name_ascending')
    (IO.read(base + 'order_by.xml').strip == xml.to_s.strip).should eql(true)
    db.delete 'users.xml'
  end

  it 'executes the insert query correctly' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'empty.xml')
    db.store 'users.xml', table
    sql = db.simple_sql

    row = generate_xml('user', name: 'Pedobear', age: '20')
    sql.insert(:row => row, :at => 'into', :element => 'data')
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'single.xml', ['name', 'age']).should eql(true)

    row = generate_xml('user', name: 'Miquel Sabaté', age: '21')
    sql.insert(:row => row, :at => 'preceding', :element => 'user')
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'users_rev.xml', ['name', 'age']).should eql(true)

    row = generate_xml('user', name: 'Another', age: '21')
    sql.insert( :row => row, :at => 'following', :element => 'user',
            :where => "name/text()='Miquel Sabaté'")
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'following.xml', ['name', 'age']).should eql(true)

    db.delete 'users.xml'
  end

  it 'executes the update query correctly' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql

    sql.update(:value => 'name', :where => "text()='Pedobear'",
               :with => '<name>Trollface</name>')
    sql.update(:value => 'user/age', :where => "../name/text()='Trollface'",
               :with => '<age>22</age>')
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'update.xml', ['name', 'age']).should eql(true)

    sql.update(:value => 'user', :where => "name/text()='Trollface'",
               :with => '<user><name>Pedobear</name><age>20</age></user>')
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'users.xml', ['name', 'age']).should eql(true)

    db.delete 'users.xml'
  end

  it 'executes the delete query correctly' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql

    sql.delete(:value => 'user')
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'empty.xml', ['name', 'age']).should eql(true)

    db.delete 'users.xml'
    db.store 'users.xml', table

    sql.delete(:value => 'user', :where => "name/text()='Another'")
    xml = sql.select(:from => 'users')
    compare_xml(xml, base + 'users_rev.xml', ['name', 'age']).should eql(true)
  end
end
