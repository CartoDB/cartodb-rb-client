require 'ostruct'
require 'oauth'
require 'typhoeus'
require 'mime/types'
require 'json/pure'
require 'active_support/core_ext/hash/slice'
require 'rgeo'
require 'rgeo/geo_json'
require 'pg'

require 'cartodb-rb-client/cartodb'
require 'cartodb-rb-client/railtie' if defined?(Rails)
