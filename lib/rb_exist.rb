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


$: << File.expand_path(File.dirname(__FILE__))
require 'existdb'


##
# == Exist module definition
#
# This module acts as a namespace for all the classes defined across
# this gem. It also defines a few pretty basic constants.
module Exist
  ##
  # Gem's name.
  NAME = 'rb_exist'

  ##
  # rb_exist is still under development.
  VERSION = '0.0.1'

  ##
  # rb_exist is licensed under the GNU Lesser General Public License
  # version 3 or (at your option) any later version.
  LICENSE = 'LGPLv3+'

  ##
  # rb_exist summary.
  SUMMARY = 'Ruby support for eXist'

  ##
  # rb_exist gem description.
  DESCRIPTION = 'A gem that gives support to the eXist DBMS.'
end
