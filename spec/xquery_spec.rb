

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

    code = IO.read(File.dirname(__FILE__) + '/example.exist')
    query = Exist::XQuery.new nil, code, params
    expected = IO.read(File.dirname(__FILE__) + '/example.expected')
    query.query.should eql(expected)
  end
end
