require 'fluent/plugin/parser'
require 'nokogiri'

module Fluent::Plugin
  class WinevtXMLparser < Parser
    Fluent::Plugin.register_parser('winevt_xml', self)

    config_param :preserve_qualifiers, :bool, default: true

    def winevt_xml?
      true
    end

    def preserve_qualifiers?
      @preserve_qualifiers
    end

    def MAKELONG(low, high)
      (low & 0xffff) | (high & 0xffff) << 16
    end

    def event_id(system_elem)
      return (system_elem/'EventID').text rescue nil if @preserve_qualifiers

      qualifiers = (system_elem/'EventID').attribute("Qualifiers").text rescue nil
      if qualifiers
        event_id = (system_elem/'EventID').text
        event_id = MAKELONG(event_id.to_i, qualifiers.to_i)
        event_id.to_s
      else
        (system_elem/'EventID').text rescue nil
      end
    end

    def parse(text)
      record = {}
      doc = Nokogiri::XML(text)
      system_elem                     = doc/'Event'/'System'
      record["ProviderName"]          = (system_elem/"Provider").attribute("Name").text rescue nil
      record["ProviderGUID"]          = (system_elem/"Provider").attribute("Guid").text rescue nil
      if @preserve_qualifiers
        record["Qualifiers"]            = (system_elem/'EventID').attribute("Qualifiers").text rescue nil
      end
      record["EventID"]               = event_id(system_elem)
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
      yield time, record
    end
  end
end
