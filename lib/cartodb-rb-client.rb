require 'ostruct'
require 'oauth'
require 'typhoeus'
require 'mime/types'
require 'json'

require 'cartodb-rb-client/cartodb'
require 'cartodb-rb-client/railtie' if defined?(Rails)