# BRCybertron - セイバートロン

BRCybertron is an Objective-C framework for executing XSLT 1.0 transforms. It is
implemented as a lightweight wrapper around [libxslt](http://xmlsoft.org/XSLT/).

# ~~Robots~~ Documents in Disguise

Here's a contrived example of how to execute an XSLT transform, using in-memory
based XML and XSLT resources:

```objc
id<CYInputSource> input = [[CYDataInputSource alloc] initWithData:
                           [@"<input><msg>Hello, BRCybertron.</msg></input>" dataUsingEncoding:NSUTF8StringEncoding]
                           options:CYParsingDefaultOptions];

CYTemplate *xslt = [CYTemplate templateWithData:
                    [@"<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' "
                     @"xmlns:xs='http://www.w3.org/2001/XMLSchema' "
                     @"exclude-result-prefixes='xs' version='1.0'>"
                     @"<xsl:output method='xml' encoding='UTF-8' />"
                     @"<xsl:template match='input'>"
                     @"<output>"
                     @"<msg><xsl:value-of select='msg'/></msg>"
                     @"<msg>More than meets the eye!</msg>"
                     @"</output>"
                     @"</xsl:template>"
                     @"</xsl:stylesheet>"
                     dataUsingEncoding:NSUTF8StringEncoding]];

// run transform, and return results as an XML string
NSString *result = [xslt transformToString:input parameters:nil error:nil];
```

At this point, `result` contains XML like:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<output>
  <msg>Hello, BRCybertron.</msg>
  <msg>More than meets the eye!</msg>
</output>
```

# XML Parsing

A big part of any XSLT workflow involves parsing XML. Not only is the input to an
XSLT transformation XML but the XSLT language itself is XML based. BRCybertron
includes support for parsing XML documents via the [CYInputSource][CYInputSource]
API, and provides [CYDataInputSource][CYDataInputSource] for parsing XML held in
memory via an `NSData` object as well as [CYFileInputSource][CYFileInputSource] for
parsing XML from a file.

# Entity Resolving

Sometimes you might be faced with XML documents that refer to unresolvable entities,
for example this document without any DTD:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<content>
  <para>&copy; 2016 Bad XML Citizen</para>
</content>
```

The `CYEntityResolver` API allows entities such as `&copy;` to be handled at runtime
in a simple way. The `CYSimpleEntityResolver` class provides a way to register simple
entity values:

```objc
[[CYSimpleEntityResolver sharedResolver] addInternalEntities:@{@"copy" : @"&#169;"}];
```

By default the XML will be resolved so that the entities are preserved, but you can
turn on entity substitution using the libxml flag `XML_PARSE_NOENT` like this:

```objc
NSData *data = [@"<content><para>&copy; 2016 Bad XML Citizen</para></content>"
                dataUsingEncoding:NSUTF8StringEncoding];
id<CYInputSource> input = [[CYDataInputSource alloc] initWithData:data
                           options:(CYParsingOptions)(XML_PARSE_NOENT)];
```

At this point, if you called `asString:error:` on `input` you'd get the following (notice
how `©` appears):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<content>
  <para>© 2016 Bad XML Citizen</para>
</content>
```

  [CYInputSource]: https://github.com/Blue-Rocket/BRCybertron/blob/master/BRCybertron/BRCybertron/CYInputSource.h
  [CYDataInputSource]: https://github.com/Blue-Rocket/BRCybertron/blob/master/BRCybertron/BRCybertron/CYDataInputSource.h
  [CYFileInputSource]: https://github.com/Blue-Rocket/BRCybertron/blob/master/BRCybertron/BRCybertron/CYFileInputSource.h
