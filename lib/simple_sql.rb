#
# Author:: Copyright (C) 2011  Miquel Sabaté (mikisabate@gmail.com)
# License::
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.
#


require 'xquery'


module Exist #:nodoc:
  ##
  # == SimpleSQL Class definition
  #
  # This class provides a set of methods that makes easier
  # to imitate SQL's select, insert and update queries. As you will
  # notice, the way to work with this class is a bit different
  # from the regular XQuery class.
  class SimpleSQL < XQuery
    ##
    # Constructor.
    #
    # @param *Exist::ExistDB* database The database connection.
    def initialize(database)
      @db, @rows = database, 0
    end

    ##
    # The _select_ query. It takes the following parameters to work:
    #
    #   - rows: the rows we want to select.
    #   - from: the table.
    #   - where: the condition to the select query.
    #   - order_by: how should the result be ordered.
    #
    # Select subqueries are not allowed since I don't know exactly
    # its behavior. Let's illustrate an example. Imagine that we
    # have a table called user with name and age as its attributes.
    # Some correct select queries would be:
    #
    #   sql = db.simple_sql # db is our Database connection
    #   sql.select(:from => 'users', :where => 'age>20')
    #   sql.select(:rows => ['age'], :from => 'users', :where => 'age>20')
    #
    # Note that the rows parameter is the only one that expects an array.
    # We may also want to order the result. In order to do that, we can
    # just call this method as follows:
    #
    #   sql.select(from: 'users', where: 'age>20', order_by: 'name_ascending')
    #
    # The result will be sorted by the name in ascending order. So, you just
    # have to write the row's name. You may also specify the ordering
    # algorithm by appending _ascending or _descending to the row's name.
    # However, be aware that this will only work with strings.
    #
    # @param *Hash* params The parameters of the query.
    #
    # @return *LibXML::XML::Document* The XML tree produced by the query.
    def select(params)
      # Raise an error if the :from parameter is not setted
      if params[:from].nil? or params[:from].empty?
        raise ArgumentError, ':from parameter nil or empty'
      end

      # First of all, let's prepare the parameters
      params[:element] = params[:from].chop #pseudo-singular
      params[:collection] = '/db' + @db.collection
      params[:row], params[:asc_desc] = order_of params[:order_by]
      params[:filter] = params[:element]
      if !params[:where].nil? and !params[:where].empty?
        params[:filter] += "[#{params[:where]}]"
      end
      generate_return_statement params[:rows]

      # Execute the query!
      kuery = read_query 'select', true
      @query = replace_tags kuery, params
      xml = execute
    end

    ##
    # The _insert_ query. It takes the following parameters to work:
    #
    #   - row: The row we want to insert.
    #   - at: Where should the inserting be done.
    #   - element: The _at_ parameter is relative to this element.
    #   - where: A condition that the element should match.
    #
    # This insert query is quite different to the SQL standard since we
    # want to take care of all the XQuery possibilities. The special magic
    # comes with the two parameters _at_ and _element_. Let's take a
    # closer look: (imagine that our database has a table 'user' which
    # is empty)
    #
    #   sql = db.simple_sql # db is our Database connection
    #   row = "<user><name>Miquel</name><age>21</age></user>"
    #   sql.insert(:row => row, :at => 'into', :element => 'data')
    #
    # With this, the row will be appended after the last child node of the
    # data element. We can also specify 'preceding' and 'following'. For
    # example, after the query above, we can now write:
    #
    #   row = "<user><name>Another</name><age>20</age></user>"
    #   sql.insert(:row => row, :at => 'preceding', :element => 'user')
    #
    # Now, this row will be inserted before the user node (in our case then,
    # before the one containing 'Miquel'). The last case is:
    #
    #    row = generate_xml('user', name: 'YetAnother', age: '21')
    #    sql.insert( :row => row, :at => 'following', :element => 'user',
    #                   :where => "name/text()='Miquel'")
    #
    # With this last query, the 'YetAnother' node will be inserted after the
    # node containing 'Miquel' and before the one containing 'Another'.
    #
    # @param *Hash* params The parameters of the query.
    #
    # @return *LibXML::XML::Document* The XML tree produced by the query.
    def insert(params)
      # Raise an ArgumentError if some the mandatory parameters are not passed
      raise ArgumentError if incorrect_params?(params, [:row, :at, :element])

      # Prepare the query
      if params[:where].nil? or params[:where].empty?
        params[:filter] = params[:element]
      else
        params[:filter] = params[:element] + '[' + params[:where] + ']'
      end

      # And finally it can be executed
      kuery = read_query 'insert'
      @query = replace_tags kuery, params
      xml = execute
    end

    ##
    # TODO
    def update(params)
      # Raise an ArgumentError if some the mandatory parameters are not passed
      raise ArgumentError if incorrect_params?(params, [:value, :with])

      
    end

    # TODO
    def delete(params)
      # TODO
    end

    private

    ##
    # Generate the return statement necessery to complete some of the
    # queries (such as select) that may vary its code because of the rows
    # to select.
    #
    # @param *Array* rows The rows to be selected.
    def generate_return_statement(rows) #:doc:
      tmp = File.new(File.dirname(__FILE__) + '/data/tmp.exist', 'w+')
      tmp.puts 'return <result>{'
      if rows.nil? or rows.empty?
        tmp.puts '$_{element}'
      else
        rows.each { |r| tmp.puts "<#{r}>{$_{element}/#{r}/text()}</#{r}>" }
      end
      tmp.puts '}</result>'
      tmp.close
    end

    ##
    # Internal method used to read the contents of the sql method template.
    # It's used just for keeping the code clean.
    #
    # @param *String* method The method's name (select, insert,...)
    #
    # @return The contents of the template.
    def read_query(method, append_return = false) #:doc:
      result = IO.read(File.dirname(__FILE__) + "/data/#{method}.exist")
      if append_return
        tmp = File.dirname(__FILE__) + "/data/tmp.exist"
        result += IO.read tmp
        FileUtils.rm tmp
      end
      result
    end

    ##
    # Internal method used to retrieve the order_by info from the
    # given parameter. By default, the order will be: order by any ascending.
    #
    # @param *String* order The value of the given order_by parameter.
    # A nil object can be passed and it will return the default ordering.
    #
    # @return *Array* A two-sized array containing the row from which to sort
    # as its first value. The second value may be 'ascending' or 'descending'.
    def order_of(order) #:doc:
      return ['any', 'ascending'] if order.nil? or order.empty?

      res = [nil, 'ascending']
      if /(.+)_(.+)$/.match(order)
        if ['ascending', 'descending'].include? $2
          res[0], res[1] = $1, $2
        end
      end
      res[0] ||= order
      res
    end

    ##
    # Check if the parameters provided by the user to the query are properly
    # setted. It only checks if the mandatory fields are not empty or nil.
    #
    # @param *Hash* params The parameters passed to this query
    #
    # @param *Array* mandatory The mandatory fields that the params hash
    # must have setted.
    #
    # @return *Boolean* false if everything is just fine, true otherwise
    def incorrect_params?(params, mandatory) #:doc:
      mandatory.each { |m| return true if params[m].nil? or params[m].empty? }
      false
    end
  end
end
