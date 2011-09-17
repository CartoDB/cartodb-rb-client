require 'rubygems'
require 'bundler/setup'

require 'ostruct'
require 'oauth'
require 'typhoeus'
require 'mime/types'
require 'active_support/core_ext/hash/slice'
require 'rgeo'
require 'rgeo/geo_json'
require 'pg'
require 'json/ext'

require 'cartodb-rb-client/cartodb'
require 'cartodb-rb-client/railtie' if defined?(Rails)

OpenSSL::SSL.send :remove_const, :VERIFY_PEER
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
