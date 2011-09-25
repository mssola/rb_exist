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


require 'uri'
require 'net/http'
require 'xquery'


module Exist #:nodoc:
  ##
  # == ExistDB Class Description
  #
  # This class makes the connection to the eXist database
  # possible. In order to execute queries, you have to instantiate
  # this class first and then call the method _query_. For example, the
  # code below works properly:
  #
  #    db = ExistDB('localhost:8080/exist/rest/db', 'locations.xml')
  #    query = 'let $l := /locations/location return $l'
  #    res = db.query(query)
  class ExistDB
    include LibXML

    ##
    # Initialize the object. Nothing fancy, just update the
    # attributes appropiately.
    #
    # @param *String* host The host we want to reach.
    #
    # @param *String* collection A relative path where our collection
    # is located.
    def initialize(host, collection = '')
      uri = URI.parse 'http://' + host
      @host, @port = uri.host, uri.port
      aux = uri.userinfo
      aux ||= ''
      @username, @password = aux.split(':')
      @collection = collection
      @path = '' + uri.path + collection
    end

    ##
    # Store the contents of an XML to a specified file located at then
    # path we already picked in the _initialize_ method. It stores a simple
    # XML defining content-type, content-length and authorization if the
    # necessary.
    #
    # @param *String* docname The name of the document.
    #
    # @param *String* xml The contents that the XML document is
    # expected to have.
    def store(docname, xml)
      Net::HTTP.start(@host, @port) do |http|
        headers = { 'Content-Type' => 'text/xml; charset=utf-8',
                    'Content-Length' => xml.length.to_s }
        unless @username.nil?
          headers['Authorization'] = @username
          headers['Authorization'] += ':' + @password unless @password.nil?
        end
        request_uri = @path + '/' + docname
        http.send_request('PUT', request_uri, xml, headers)
      end
    end

    ##
    # Sends a DELETE request for the given document name.
    #
    # @param *String* delete The name of the document to delete.
    def delete(docname)
      Net::HTTP.start(@host, @port) do |http|
        request_uri =  @path + '/' + docname
        http.delete request_uri
      end
    end

    ##
    # Packages the given query into an XML and then it sends this
    # document to eXist through a POST request. This method is only meant
    # to be used by the Exist::XQuery class, don't use it on your code.
    #
    # @param *String* query The query ready to be sent tp eXist.
    #
    # @return *Net::HTTPResponse* The response to our request.
    def do_post(query)
      xml = package_query query
      response = ''
      Net::HTTP.start(@host, @port) do |http|
        headers = { 'Content-Type' => 'text/xml; charset=utf-8',
                    'Content-Length' => xml.length.to_s }
        response = http.send_request('POST', @path, xml, headers)
      end
      response
    end

    ##
    # Creates a new _XQuery_ object from the given code. The given
    # arguments are replaced in the query. A well-formatted query would be:
    #
    #    let foo := '_{parameter}, _{another}'
    #
    # The parameters are represented with a hash. Passing the following hash
    # { :parameter => 'hola', :another => 'adeu' } will produce:
    #
    #    let foo := 'hola, adeu'
    #
    # Please, use this method instead of creating an Exist::XQuery object
    # by yourself.
    #
    # @param *String* code The code for the query.
    #
    # @param *Hash* args Parameters to pass into the query.
    def query(code, args)
      Exist::XQuery.new(self, code, args)
    end

    ##
    # Execute an eXist query from a file.
    #
    # @param *String* filename The name of the file containing the query.
    #
    # @param *Hash* args Parameters to pass into the query.
    def query_from_file(filename, args)
      code = IO.read filename
      query(code, args)
    end

    ##
    # TODO: it does not work yet
    def move(source, destination)
      xquery = <<-XQUERY
        let $status := xmldb:move('_{source}', '_{dest}', '_{resource}')
        return <status>{$status}</status>
      XQUERY
      params = { :source => source, :dest => destination,
                 :resource => @collection }
      kuery = query(xquery, params)
      kuery.execute
    end

    ##
    # Renames the given document.
    #
    # @param *String* source The name of the file.
    #
    # @param *String* name The new name for the specified file.
    def rename(source, name)
      xquery = <<-XQUERY
        let $status := xmldb:rename('_{col}', '_{source}', '_{name}')
        return <status>{$status}</status>
      XQUERY

      params = { :col => @collection, :source => source, :name => name }
      kuery = query(xquery, params)
      kuery.execute
    end

    ##
    # TODO: it does not work yet
    def copy(source, dest)
      if !@collection.empty? and !source.start_with?('/')
        source = @collection + '/' + source
      end
      if !@collection.empty? and !dest.start_with?('/')
        dest = @collection + '/' + dest
      end
      params = { :source => source, :srccol => @collection,
                 :srcres => source, :dest => dest }
      file = File.dirname(__FILE__) + '/data/copy.exist'
      kuery = query_from_file(file, params)
      kuery.execute
    end

    ##
    # Re-implementing the to_s method for testing purposes.
    def to_s
      "#{@host}:#{@port},#{@username},#{@password},#{@collection},#{@path}"
    end

    private

    ##
    # Package up an XQuery in an XML tree.
    #
    # @param *String* code The code for the query.
    def package_query(code)
      # Create the XML Document
      doc = XML::Document.new()
      doc.root = XML::Node.new('query')
      doc.root['max'] = 'nil'
      doc.root['start'] = '1'
      doc.root['xmlns'] = 'http://exist.sourceforge.net/NS/exist'

      # Add the XQuery into it
      text = XML::Node.new('text')
      text << code
      doc.root << text
      doc.to_s.strip.sub("\n", '')
    end
  end
end
