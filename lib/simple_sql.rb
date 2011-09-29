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
    #   - from: the table.
    #   - where: the condition to the select query.
    #   - TODO: to implement order by,
    #
    # Select subqueries are not allowed since I don't know exactly
    # its behavior. Let's illustrate an example. Imagine that we
    # have a table called user with name and age as its attributes.
    # A correct select query would be:
    #
    #   sql = db.simple_sql # db is our Database connection
    #   sql.select(:from => 'users', :where => 'age>20')
    #
    # Obviously, we can check the number of matches by calling the
    # instance method SimpleSQL#count.
    #
    # @return *LibXML::XML::Document* The XML tree produced by the query.
    def select(params)
      # First of all, let's prepare the query
      kuery = read_query 'select'
      params[:element] = singular_of(params[:from])
      params[:collection] = '/db' + @db.collection
      params[:filter] = params[:element]
      if !params[:where].nil? and !params[:where].empty?
        params[:filter] += "[#{params[:where]}]"
      end

      # Execute the query!
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

    ##
    # Class method used to identify if a given query kind corresponds
    # to an sql query.
    #
    # @param *Symbol* kind The given kind to evaluate.
    #
    # @return *Boolean* true if this is an invalid kind, false otherwise.
    def self.invalid?(kind)
      ![:Select, :Insert, :Update].include?(kind.capitalize)
    end

    private

    ##
    # TODO
    def read_query(method)
      IO.read(File.dirname(__FILE__) + "/data/#{method}.exist")
    end

    ##
    # TODO
    def singular_of(word)
      # TODO
      word.chop
    end
  end
end
