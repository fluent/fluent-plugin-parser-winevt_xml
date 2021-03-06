require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fluent/test'

require 'fluent/test/driver/parser'
require 'fluent/plugin/parser_winevt_xml'
require 'fluent/plugin/parser_winevt_sax'

class Test::Unit::TestCase
end
require 'fluent/test/helpers'

include Fluent::Test::Helpers
