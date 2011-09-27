
db = Exist::ExistDB.new('localhost:8080/exist/rest/db')
sql = db.simple_sql
xml = sql.select(:from => 'users')
puts xml
