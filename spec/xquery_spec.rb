
def user_query(where)
  db = Exist::ExistDB.new('localhost:8080/exist/rest/db')
  table = IO.read(File.dirname(__FILE__) + '/data/users.xml')
  db.store 'users.xml', table
  xquery = <<-XQUERY
    xquery version "1.0";

    let $users := '/db'
    return
    <users>
    {
      for $user in (collection($users)//user)
      return
        $user/name
    }
    </users>
  XQUERY
  kuery = db.query xquery
  xml = kuery.execute
  puts xml
  db.delete 'users.xml'
  kuery.count
end


describe 'XQuery' do
  it 'replaces the tags correctly' do
    code = '_{hello}, and and and _{bye}'
    args = { hello: 'hola', bye: 'ciao!' }
    query = Exist::XQuery.new nil, code, args
    query.query.should eql('hola, and and and ciao!')

    code = '_hello}, and and and _{bye}'
    query = Exist::XQuery.new nil, code, args
    query.query.should eql('_hello}, and and and ciao!')

    code = '_{hola}, and and and _{bye}'
    query = Exist::XQuery.new nil, code, args
    query.query.should eql('_{hola}, and and and ciao!')

    code = "let $status := xmldb:copy('_{srccol}', '_{dest}', '_{srcres}')"
    params = { source: 'source', srccol: 'src_col',
                 srcres: 'src_res', dest: 'dest' }
    query = Exist::XQuery.new nil, code, params
    query.query.should eql("let $status := xmldb:copy('src_col', 'dest', 'src_res')")

    code = IO.read(File.dirname(__FILE__) + '/data/example.exist')
    query = Exist::XQuery.new nil, code, params
    expected = IO.read(File.dirname(__FILE__) + '/data/example.expected')
    query.query.should eql(expected)
  end

  it 'retrieves the number of matches produced by the query' do
#     xml = user_query('edat>20')
#     puts xml
  end
end
