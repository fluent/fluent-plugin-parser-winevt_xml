# fluent-plugin-parser-winevt_xml

[![Build status](https://ci.appveyor.com/api/projects/status/eb0capv0q70u381f/branch/master?svg=true)](https://ci.appveyor.com/project/fluent/fluent-plugin-parser-winevt-xml/branch/master)
[![Build Status](https://travis-ci.org/fluent/fluent-plugin-parser-winevt_xml.svg?branch=master)](https://travis-ci.org/fluent/fluent-plugin-parser-winevt_xml)

## Component

### Fluentd Parser plugin for XML rendered Windows EventLogs

[Fluentd](https://www.fluentd.org/) plugin to parse XML rendered Windows Event Logs.

### Installation

```
gem install fluent-plugin-parser-winevt_xml
```

## Configuration

```aconf
<parse>
  @type winevt_xml
</parse>
```

## Copyright

### Copyright

Copyright(C) 2019- Hiroshi Hatake, Masahiro Nakagawa

### License

Apache License, Version 2.0
