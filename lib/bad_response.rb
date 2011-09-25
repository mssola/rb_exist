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


module Exist #:nodoc:
  ##
  # This is the specific exception for bad responses. Generally, it
  # should be raised when the response of an XQuery execution has as its
  # root element an <exception>.
  class BadResponse < Exception
    ##
    # Constructor
    #
    # @param *Net::HTTPResponse* res The http response for the query.
    def initialize(res)
      @code, @msg, @body = res.code, res.message, res.body
    end

    ##
    # Re-implemented to show a more detailed information about
    # this exception.
    def to_s
      "Response #{@code} #{@msg}: #{@body}"
    end
  end
end
