
describe 'SimpleSQL' do
  it 'executes the select query correctly' do
    db = Exist::ExistDB.new("#{$server_ip}/db")
    table = IO.read(File.dirname(__FILE__) + '/data/users.xml')
    db.store 'users.xml', table
    sql = db.simple_sql
    sql.select(:from => 'users')
    sql.count.should eql('2')
    sql.select(:from => 'users',
               :where => 'edat>20')
    sql.count.should eql('1')
    sql.select(:from => 'users',
               :where => 'edat<19')
    sql.count.should eql('0')
    sql.select(:from => 'users',
               :where => 'edat>19')
    sql.count.should eql('2')
    sql.select(:from => 'users',
               :where => '')
    sql.count.should eql('2')
    db.delete 'users.xml'
  end

  pending 'it executes the insert query correctly'
  pending 'it executes the update query correctly'
end
