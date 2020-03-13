require 'nokogiri'

class WinevtXMLDocument < Nokogiri::XML::SAX::Document
  def initialize(preserve_qualifiers)
    @stack = []
    @result = {}
    @preserve_qualifiers = preserve_qualifiers
    super()
  end

  def MAKELONG(low, high)
    ((low & 0xffff) | (high & 0xffff)) << 16
  end

  def event_id
    if @result.has_key?("Qualifiers")
      qualifiers = @result.delete("Qualifiers")
      event_id = @result['EventID']
      event_id = MAKELONG(qualifiers.to_i, event_id.to_i)
      @result['EventID'] = event_id.to_s
    else
      @result['EventID']
    end
  end

  def result
    return @result if @preserve_qualifiers

    if @result
      @result['EventID'] = event_id
    end
    @result
  end

  def start_document
  end

  def start_element(name, attributes = [])
    @stack << name

    if name == "Provider"
      @result["ProviderName"] = attributes[0][1] rescue nil
      @result["ProviderGUID"] = attributes[1][1] rescue nil
    elsif name == "EventID"
      @result["Qualifiers"] = attributes[0][1] rescue nil
    elsif name == "TimeCreated"
      @result["TimeCreated"] = attributes[0][1] rescue nil
    elsif name == "Correlation"
      @result["ActivityID"] = attributes[0][1] rescue nil
      @result["RelatedActivityID"] = attributes[1][1] rescue nil
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
