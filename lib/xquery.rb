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


require 'libxml'
require 'bad_response'


module Exist #:nodoc:
  ##
  # == XQuery Class Definition
  #
  # Represents a query. Please don't create an Exist::XQuery instance
  # directly, try using Exist::ExistDB#query instead. To execute the
  # query just call to the _execute_ method. If you just want to know,
  # the number of matches that the query produces, use one of the following
  # methods: _count_, _length_ or _size_.
  class XQuery
    include LibXML

    # Just read its value for debugging purposes.
    attr_reader :query

    ##
    # Constructor.
    #
    # @param *Exist::ExistDB* db The database connection.
    #
    # @param *String* code The code for the query.
    #
    # @param *Hash* args Parameters to pass into the query.
    def initialize(db, code, args)
      @db = db
      @query = replace_tags code, args
      @rows = 0
    end

    ##
    # Returns the number of matches that the query produces. It
    # may also be called through its aliases: _length_ and _size_.
    def count
      @rows
    end

    ##
    # Some aliases to the count method.
    alias :length :count
    alias :size :count

    ##
    # Executes the query and retrieves the result.
    #
    # @return *LibXML::XML::Document* The XML tree produced by the query.
    def execute
      res = @db.do_post @query
      xml = XML::Document.string(res.body)
      begin
        raise BadResponse, res
      rescue BadResponse => e
        puts 'Bad Response!'
        puts e.message
        @rows = 0
        return nil
      end if xml.root.name == 'exception'
      @rows = xml.root['hits']
      xml
    end

    private

    ##
    # Replaces all the tags inside the code with the given args.
    #
    # @param *String* code The query with the tags not replaced.
    #
    # @param *Hash* args Parameters to pass into the query.
    #
    # @return *String* The code with all the well-formatted tags replaced.
    def replace_tags(code, args) #:doc:
      # The splitting-joining is to avoid some issues around end of
      # line characters.
      aux = code.split("\n")
      args.each do |key, value|
        aux.map! { |str| str.sub("_{#{key.to_s}}", value) }
      end
      aux.join("\n")
    end
  end
end 
