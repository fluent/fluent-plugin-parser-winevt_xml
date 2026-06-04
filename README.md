# fluent-plugin-parser-winevt_xml

[![Test on macOS](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/macos-test.yaml/badge.svg)](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/macos-test.yaml)
[![Test on Ubuntu](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/linux-test.yaml/badge.svg)](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/linux-test.yaml)
[![Test on Windows](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/windows-test.yaml/badge.svg)](https://github.com/fluent/fluent-plugin-parser-winevt_xml/actions/workflows/windows-test.yaml)

## Component

### Fluentd Parser plugin for XML rendered Windows EventLogs

[Fluentd](https://www.fluentd.org/) plugin to parse XML rendered Windows Event Logs.

### Installation

```
gem install fluent-plugin-parser-winevt_xml
```

## Configuration

### parser_winevt_xml

```aconf
<parse>
  @type winevt_xml
  preserve_qualifiers true
</parse>
```

#### preserve_qualifiers

Preserve Qualifiers key instead of calculating actual EventID with Qualifiers. Default is `true`.

### parser_winevt_sax

This plugin is a bit faster than `winevt_xml`.

```aconf
<parse>
  @type winevt_sax
  preserve_qualifiers true
</parse>
```

#### preserve_qualifiers

Preserve Qualifiers key instead of calculating actual EventID with Qualifiers. Default is `true`.

## Copyright

### Copyright

Copyright(C) 2019- Hiroshi Hatake, Masahiro Nakagawa

### License

Apache License, Version 2.0
