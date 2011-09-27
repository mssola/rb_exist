

describe 'ExistDB' do
  it 'creates a new database connection' do
    db = Exist::ExistDB.new('localhost:8080/exist/rest/db', '/awesome.xml')
    db.to_s.should eql('localhost:8080,,,/awesome.xml,/exist/rest/db/awesome.xml')

    db = Exist::ExistDB.new('localhost:8080')
    db.to_s.should eql('localhost:8080,,,,')

    db = Exist::ExistDB.new('localhost')
    db.to_s.should eql('localhost:80,,,,')

    db = Exist::ExistDB.new('mssola:hola@localhost:8080')
    db.to_s.should eql('localhost:8080,mssola,hola,,')

    db = Exist::ExistDB.new('mssola:@localhost:8080')
    db.to_s.should eql('localhost:8080,mssola,,,')

    db = Exist::ExistDB.new('mssola@localhost')
    db.to_s.should eql('localhost:80,mssola,,,')
  end
end
