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
  # to imitate SQL's select, insert and update queries.
  class SimpleSQL < XQuery
    ##
    # Constructor.
    #
    # @param *Exist::ExistDB* database The database connection.
    def initialize(database)
      @db, @rows = database, 0
    end

    ##
    # TODO
    def select(params)
      kuery = read_query 'select'
      params[:element] = singular_of(params[:from])
      params[:collection] = '/db' + @db.collection
      @query = replace_tags kuery, params
#       puts @query
      xml = execute
      xml
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
