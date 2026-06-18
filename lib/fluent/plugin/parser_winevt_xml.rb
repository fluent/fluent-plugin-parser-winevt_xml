require 'fluent/plugin/parser'

module Fluent::Plugin
  class WinevtXMLparser < Parser
    Fluent::Plugin.register_parser('winevt_xml', self)

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
        require 'rexml/document'
      end
    end

    def winevt_xml?
      true
    end

    def preserve_qualifiers?
      @preserve_qualifiers
    end

    def MAKELONG(low, high)
      (low & 0xffff) | (high & 0xffff) << 16
    end

    def event_id_nokogiri(system_elem)
      if @preserve_qualifiers
        return ((system_elem/'EventID').text rescue nil)
      end

      qualifiers = (system_elem/'EventID').attribute("Qualifiers").text rescue nil
      if qualifiers
        event_id = (system_elem/'EventID').text
        event_id = MAKELONG(event_id.to_i, qualifiers.to_i)
        event_id.to_s
      else
        (system_elem/'EventID').text rescue nil
      end
    end

    def event_id_rexml(system_elem)
      return system_elem.elements['EventID'].text rescue nil if @preserve_qualifiers

      qualifiers = system_elem.elements['EventID'].attributes['Qualifiers'] rescue nil
      if qualifiers
        event_id = system_elem.elements['EventID'].text
        event_id = MAKELONG(event_id.to_i, qualifiers.to_i)
        event_id.to_s
      else
        system_elem.elements['EventID'].text rescue nil
      end
    end

    def parse_nokogiri(text)
      record = {}
      doc = Nokogiri::XML(text)
      system_elem                     = doc/'Event'/'System'
      record["ProviderName"]          = (system_elem/"Provider").attribute("Name").text rescue nil
      record["ProviderGUID"]          = (system_elem/"Provider").attribute("Guid").text rescue nil
      if @preserve_qualifiers
        record["Qualifiers"]          = (system_elem/'EventID').attribute("Qualifiers").text rescue nil
      end
      record["EventID"]               = event_id_nokogiri(system_elem)
      record["Level"]                 = (system_elem/'Level').text rescue nil
      record["Task"]                  = (system_elem/'Task').text rescue nil
      record["Opcode"]                = (system_elem/'Opcode').text rescue nil
      record["Keywords"]              = (system_elem/'Keywords').text rescue nil
      record["TimeCreated"]           = (system_elem/'TimeCreated').attribute("SystemTime").text rescue nil
      record["EventRecordID"]         = (system_elem/'EventRecordID').text rescue nil
      record["ActivityID"]            = (system_elem/'Correlation').attribute('ActivityID').text rescue nil
      record["RelatedActivityID"]     = (system_elem/'Correlation').attribute("RelatedActivityID").text rescue nil
      record["ThreadID"]              = (system_elem/'Execution').attribute("ThreadID").text rescue nil
      record["ProcessID"]             = (system_elem/'Execution').attribute("ProcessID").text rescue nil
      record["Channel"]               = (system_elem/'Channel').text rescue nil
      record["Computer"]              = (system_elem/"Computer").text rescue nil
      record["UserID"]                = (system_elem/'Security').attribute("UserID").text rescue nil
      record["Version"]               = (system_elem/'Version').text rescue nil
      time = @estimate_current_event ? Fluent::EventTime.now : nil
      return time, record
    end

    def parse_rexml(text)
      record = {}
      doc = REXML::Document.new(text)
      system_elem = doc.root.elements['System'] rescue nil
      record["ProviderName"]      = system_elem.elements['Provider'].attributes['Name'] rescue nil
      record["ProviderGUID"]      = system_elem.elements['Provider'].attributes['Guid'] rescue nil
      if @preserve_qualifiers
        record["Qualifiers"]      = system_elem.elements['EventID'].attributes['Qualifiers'] rescue nil
      end
      record["EventID"]           = event_id_rexml(system_elem)
      record["Level"]             = system_elem.elements['Level'].text rescue nil
      record["Task"]              = system_elem.elements['Task'].text rescue nil
      record["Opcode"]            = system_elem.elements['Opcode'].text rescue nil
      record["Keywords"]          = system_elem.elements['Keywords'].text rescue nil
      record["TimeCreated"]       = system_elem.elements['TimeCreated'].attributes['SystemTime'] rescue nil
      record["EventRecordID"]     = system_elem.elements['EventRecordID'].text rescue nil
      record["ActivityID"]        = system_elem.elements['Correlation'].attributes['ActivityID'] rescue nil
      record["RelatedActivityID"] = system_elem.elements['Correlation'].attributes['RelatedActivityID'] rescue nil
      record["ThreadID"]          = system_elem.elements['Execution'].attributes['ThreadID'] rescue nil
      record["ProcessID"]         = system_elem.elements['Execution'].attributes['ProcessID'] rescue nil
      record["Channel"]           = system_elem.elements['Channel'].text rescue nil
      record["Computer"]          = system_elem.elements['Computer'].text rescue nil
      record["UserID"]            = system_elem.elements['Security'].attributes['UserID'] rescue nil
      record["Version"]           = system_elem.elements['Version'].text rescue nil
      time = @estimate_current_event ? Fluent::EventTime.now : nil
      return time, record
    end

    def parse(text)
      if @use_nokogiri
        time, record = parse_nokogiri(text)
      else
        time, record = parse_rexml(text)
      end
      yield time, record
    end
  end
end
