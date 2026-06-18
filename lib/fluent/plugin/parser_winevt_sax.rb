require 'fluent/plugin/parser'

module Fluent::Plugin
  class WinevtSAXparser < Parser
    Fluent::Plugin.register_parser('winevt_sax', self)

    config_param :preserve_qualifiers, :bool, default: true
    config_param :parser, :enum, list: [:auto, :rexml, :nokogiri], default: :auto

    def initialize
      super
      @use_nokogiri = false
    end

    def configure(conf)
      super
      if @parser != :rexml
        begin
          require 'nokogiri'
          require 'fluent/plugin/winevt_sax_document_nokogiri'
          @use_nokogiri = true
        rescue
          if @parser == :nokogiri
            raise Fluent::ConfigError,
                  "Nokogiri is required when 'parser nokogiri' is specified, but it isn't installed. " \
                  "Install nokogiri, or set 'parser' to 'rexml' or 'auto': #{e.message}"
          end
        end
      end

      if !@use_nokogiri
        require 'rexml/parsers/sax2parser'
        require 'fluent/plugin/winevt_sax_document_rexml'
      end
    end

    def winevt_xml?
      true
    end

    def preserve_qualifiers?
      @preserve_qualifiers
    end

    def parse(text)
      if @use_nokogiri
        evtxml = WinevtXMLDocumentNokogiri.new(@preserve_qualifiers)
        parser = Nokogiri::XML::SAX::Parser.new(evtxml)
        parser.parse(text)
      else
        evtxml = WinevtXMLDocumentREXML.new(@preserve_qualifiers)
        parser = REXML::Parsers::SAX2Parser.new(text)
        parser.listen(evtxml)
        parser.parse
      end
      time = @estimate_current_event ? Fluent::EventTime.now : nil
      yield time, evtxml.result
    end
  end
end
