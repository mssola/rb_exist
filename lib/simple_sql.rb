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
    # The select query. It takes the following parameters to work:
    #
    #   - rows: TODO
    #   - from: the table.
    #   - where: the condition to the select query.
    #   - order_by: how should the result be ordered.
    #
    # Select subqueries are not allowed since I don't know exactly
    # its behavior. Let's illustrate an example. Imagine that we
    # have a table called user with name and age as its attributes.
    # A correct select query would be:
    #
    #   sql = db.simple_sql # db is our Database connection
    #   sql.select(:from => 'users', :where => 'age>20')
    #
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
    # Finally, we can check the number of matches by calling the
    # instance method SimpleSQL#count.
    #
    # @return *LibXML::XML::Document* The XML tree produced by the query.
    def select(params)
      # First of all, let's prepare the parameters
      params[:element] = params[:from].chop #pseudo-singular
      params[:collection] = '/db' + @db.collection
      params[:row], params[:asc_desc] = order_of params[:order_by]
      params[:filter] = params[:element]
      if !params[:where].nil? and !params[:where].empty?
        params[:filter] += "[#{params[:where]}]"
      end

      # Execute the query!
      kuery = read_query 'select'
      @query = replace_tags kuery, params
      xml = execute
    end

    ##
    # TODO
    def insert(params)
      # TODO
    end

    ##
    # TODO
    def update(params)
      # TODO
    end

    private

    ##
    # Internal method used to read the contents of the sql method template.
    # It's used just for keeping the code clean.
    #
    # @param *String* method The method's name (select, insert,...)
    #
    # @return The contents of the template.
    def read_query(method)
      IO.read(File.dirname(__FILE__) + "/data/#{method}.exist")
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
  end
end
