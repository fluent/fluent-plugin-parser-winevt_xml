require_relative '../helper'

class WinevtSAXparserTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[]
  XMLLOG = File.open(File.join(__dir__, "..", "data", "eventlog.xml") )

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::WinevtSAXparser).configure(conf)
  end

  def test_parse
    d = create_driver
    xml = XMLLOG
    expected = {"ProviderName"      => "Microsoft-Windows-Security-Auditing",
                "ProviderGUID"      => "{54849625-5478-4994-A5BA-3E3B0328C30D}",
                "EventID"           => "4624",
                "Qualifiers"        => nil,
                "Level"             => "0",
                "Task"              => "12544",
                "Opcode"            => "0",
                "Keywords"          => "0x8020000000000000",
                "TimeCreated"       => "2019-06-13T09:21:23.345889600Z",
                "EventRecordID"     => "80688",
                "ActivityID"        => "{587F0743-1F71-0006-5007-7F58711FD501}",
                "RelatedActivityID" => nil,
                "ProcessID"         => "912",
                "ThreadID"          => "24708",
                "Channel"           => "Security",
                "Computer"          => "Fluentd-Developing-Windows",
                "UserID"            => nil,
                "Version"           => "2",}
    d.instance.parse(xml) do |time, record|
      assert_equal(expected, record)
    end

    assert_true(d.instance.winevt_xml?)
  end

  class QualifiersTest < self
    def setup
      @xml = File.open(File.join(__dir__, "..", "data", "eventlog-with-qualifiers.xml"))
    end

    def teardown
      @xml.close
    end

    def test_parse_without_qualifiers
      d = create_driver CONFIG + %[preserve_qualifiers false]
      expected = {"ActivityID"        => nil,
                  "Channel"           => "Application",
                  "Computer"          => "DESKTOP-G457RDR",
                  "EventID"           => "3221241866",
                  "EventRecordID"     => "150731",
                  "Keywords"          => "0x80000000000000",
                  "Level"             => "4",
                  "Opcode"            => "0",
                  "ProcessID"         => "0",
                  "ProviderGUID"      => "{E23B33B0-C8C9-472C-A5F9-F2BDFEA0F156}",
                  "ProviderName"      => "Microsoft-Windows-Security-SPP",
                  "RelatedActivityID" => nil,
                  "Task"              => "0",
                  "ThreadID"          => "0",
                  "TimeCreated"       => "2020-01-16T09:57:18.013693700Z",
                  "UserID"            => nil,
                  "Version"           => "0"}
      d.instance.parse(@xml) do |time, record|
        assert_equal(expected, record)
      end

      assert_true(d.instance.winevt_xml?)
    end
  end
end
