require 'ostruct'
require 'oauth'
require 'typhoeus'
require 'mime/types'
require 'json'
require 'active_support/core_ext/hash/slice'

require 'cartodb-rb-client/cartodb'
require 'cartodb-rb-client/railtie' if defined?(Rails)