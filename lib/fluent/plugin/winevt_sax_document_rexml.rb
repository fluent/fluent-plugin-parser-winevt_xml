require 'rexml/parsers/sax2parser'

class WinevtXMLDocumentREXML
  def initialize(preserve_qualifiers)
    @stack = []
    @result = {}
    @preserve_qualifiers = preserve_qualifiers
  end

  def MAKELONG(low, high)
    (low & 0xffff) | (high & 0xffff) << 16
  end

  def event_id
    if @result.has_key?("Qualifiers")
      qualifiers = @result.delete("Qualifiers")
      event_id = @result['EventID']
      event_id = MAKELONG(event_id.to_i, qualifiers.to_i)
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

  def start_element(*args)
    # REXML SAX2 may pass (uri, localname, qname, attributes) or (qname, attributes)
    name = if args.length >= 3
             args[1].to_s
           else
             args[0].to_s
           end
    # normalize namespace/prefix
    name = name.split('}').last if name.include?('}')
    name = name.split(':').last if name.include?(':')
    @stack << name

    attrs = args.last || {}

    # helper to fetch attribute value from different attribute containers
    get_attr = lambda do |a, k|
      begin
        if a.is_a?(Array)
          pair = a.find { |p| p && p[0] && p[0].to_s == k.to_s }
          pair && pair[1]
        elsif a.respond_to?(:[])
          a[k] || a[k.to_sym]
        else
          nil
        end
      rescue
        nil
      end
    end

    if name == "Provider"
      @result["ProviderName"] = get_attr.call(attrs, 'Name')
      @result["ProviderGUID"] = get_attr.call(attrs, 'Guid')
    elsif name == "EventID"
      @result["Qualifiers"] = get_attr.call(attrs, 'Qualifiers')
    elsif name == "TimeCreated"
      @result["TimeCreated"] = get_attr.call(attrs, 'SystemTime')
    elsif name == "Correlation"
      @result["ActivityID"] = get_attr.call(attrs, 'ActivityID')
      @result["RelatedActivityID"] = get_attr.call(attrs, 'RelatedActivityID')
    elsif name == "Execution"
      @result["ProcessID"] = get_attr.call(attrs, 'ProcessID')
      @result["ThreadID"] = get_attr.call(attrs, 'ThreadID')
    elsif name == "Security"
      @result["UserID"] = get_attr.call(attrs, 'UserID')
    end
  end

  def characters(string)
    element = @stack.last
    return unless element

    if /^EventID|Level|Task|Opcode|Keywords|EventRecordID|ActivityID|Channel|Computer|Security|Version$/ === element
      @result[element] = (@result[element] || '') + string
    end
  end

  def end_element(*_)
    @stack.pop
  end

  def method_missing(name, *args, &block)
    # Ignore any SAX2 events we don't explicitly handle (e.g., progress)
  end
end
