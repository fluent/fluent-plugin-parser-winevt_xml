require 'fluent/plugin/parser'
require 'fluent/plugin/winevt_sax_document'
require 'nokogiri'

module Fluent::Plugin
  class WinevtSAXparser < Parser
    Fluent::Plugin.register_parser('winevt_sax', self)

    def winevt_xml?
      true
    end

    def parse(text)
      evtxml = WinevtXMLDocument.new
      parser = Nokogiri::XML::SAX::Parser.new(evtxml)
      parser.parse(text)
      time = @estimate_current_event ? Fluent::EventTime.now : nil
      yield time, evtxml.result
    end
  end
end
