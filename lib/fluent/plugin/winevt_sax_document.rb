require 'nokogiri'

class WinevtXMLDocument < Nokogiri::XML::SAX::Document
  attr_reader :result

  def initialize
    @stack = []
    @result = {}
    super
  end

  def start_document
  end

  def start_element(name, attributes = [])
    @stack << name

    if name == "Provider"
      @result["PrividerName"] = attributes[0][1] rescue nil
      @result["ProviderGUID"] = attributes[1][1] rescue nil
    elsif name == "EventID"
      @result["Qualifiers"] = attributes[0][1] rescue nil
    elsif name == "TimeCreated"
      @result["TimeCreated"] = attributes[0][1] rescue nil
    elsif name == "Correlation"
      @result["RelatedActivityID"] = attributes[0][1] rescue nil
    elsif name == "Execution"
      @result["ProcessID"] = attributes[0][1] rescue nil
      @result["ThreadID"] = attributes[1][1] rescue nil
    elsif name == "Security"
      @result["UserID"] = attributes[0][1] rescue nil
    end
  end

  def characters(string)
    element = @stack.last

    if /^EventID|Level|Task|Opcode|Keywords|EventRecordID|
        ActivityID|Channel|Computer|Security|Version$/ === element
      @result[element] = string
    end
  end

  def end_element(name, attributes = [])
  end

  def end_document
  end
end
