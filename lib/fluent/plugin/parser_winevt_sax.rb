require 'fluent/plugin/parser'
require 'fluent/plugin/winevt_sax_document'
require 'nokogiri'

module Fluent::Plugin
  class WinevtSAXparser < Parser
    Fluent::Plugin.register_parser('winevt_sax', self)

    config_param :preserve_qualifiers, :bool, default: true

    def winevt_xml?
      true
    end

    def preserve_qualifiers?
      @preserve_qualifiers
    end

    def parse(text)
      evtxml = WinevtXMLDocument.new(@preserve_qualifiers)
      parser = Nokogiri::XML::SAX::Parser.new(evtxml)
      parser.parse(text)
      time = @estimate_current_event ? Fluent::EventTime.now : nil
      yield time, evtxml.result
    end
  end
end
