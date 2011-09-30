
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

# Let the testing begin!

describe 'SimpleSQL' do
  it 'raises an exception if the from parameter is not setted' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    base =File.dirname(__FILE__) + '/data/'
    table = IO.read(base + 'users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql
    expect{sql.select({})}.to raise_error(ArgumentError)
    expect{sql.select({ :where => 'age>20'})}.to raise_error(ArgumentError)
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

  pending 'it executes the insert query correctly'
  pending 'it executes the update query correctly'
end
