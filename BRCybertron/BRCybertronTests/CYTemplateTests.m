//
//  CYTemplateTests.m
//  BRCybertron
//
//  Created by Matt on 7/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <libxml/parser.h>
#import "CYDataInputSource.h"
#import "CYFileInputSource.h"
#import "CYTemplate.h"

@interface CYTemplateTests : XCTestCase

@end

@implementation CYTemplateTests

- (NSString *)pathForTestXSLResource:(NSString *)name {
	return [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil inDirectory:@"TestResources"];
}

- (NSData *)testXSLDataForResource:(NSString *)name {
	NSString *path = [self pathForTestXSLResource:name];
	return [NSData dataWithContentsOfFile:path];
}

- (void)testTransformSimple {
	NSData *xsltData = [self testXSLDataForResource:@"simple-to-html.xsl"];
	CYTemplate *tmpl = [CYTemplate templateWithData:xsltData];
	CYDataInputSource *xml = [[CYDataInputSource alloc] initWithData:[@"<passage><para>Hello, world.</para></passage>" dataUsingEncoding:NSUTF8StringEncoding]
															 options:CYParsingAsHTML];
	
	NSError *error = nil;
	NSString *result = [tmpl transformToString:xml parameters:nil error:&error];
	assertThat(error, nilValue());
	NSString *expected = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n"
						@"<html><body><p>Hello, world.</p></body></html>\n";
	assertThat(result, equalTo(expected));
}

- (void)testTransformWithParams {
	NSData *xsltData = [self testXSLDataForResource:@"params-to-html.xsl"];
	NSDictionary<NSString *, id> *params = @{@"strength" : @98.9, @"prowess" : @"unparalleled"};
	CYTemplate *tmpl = [CYTemplate templateWithData:xsltData];
	CYDataInputSource *xml = [[CYDataInputSource alloc] initWithData:[@"<passage><para>Hello, world.</para></passage>" dataUsingEncoding:NSUTF8StringEncoding]
															 options:CYParsingAsHTML];
	
	NSError *error = nil;
	NSString *result = [tmpl transformToString:xml parameters:params error:&error];
	assertThat(error, nilValue());
	NSString *expected = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n"
						@"<html><body>\n<p>Hello, world.</p>\n<dl>\n<dt>Strength</dt>\n<dd>99%</dd>\n<dt>Prowess</dt>\n<dd>unparalleled</dd>\n</dl>\n</body></html>\n";
	assertThat(result, equalTo(expected));
}

- (void)testTransformFileWithParams {
	NSString *xsltFile = [self pathForTestXSLResource:@"params-to-html.xsl"];
	CYTemplate *tmpl = [CYTemplate templateWithContentsOfFile:xsltFile];
	NSString *xmlFile = [self pathForTestXSLResource:@"params-to-html.xml"];
	CYFileInputSource *xml = [[CYFileInputSource alloc] initWithContentsOfFile:xmlFile options:CYParsingDefaultOptions];
	NSDictionary<NSString *, id> *params = @{@"strength" : @98.9, @"prowess" : @"unparalleled"};
	
	NSError *error = nil;
	NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"params-to-html.html"];
	[[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
	[tmpl transform:xml parameters:params toFile:outPath error:&error];
	assertThat(error, nilValue());
	NSString *result = [NSString stringWithContentsOfFile:outPath encoding:NSUTF8StringEncoding error:nil];
	NSString *expected = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n"
						@"<html><body>\n<p>Hello, world.</p>\n<dl>\n<dt>Strength</dt>\n<dd>99%</dd>\n<dt>Prowess</dt>\n<dd>unparalleled</dd>\n</dl>\n</body></html>\n";
	assertThat(result, equalTo(expected));
}

- (void)testTransformJSON {
	NSData *xsltData = [self testXSLDataForResource:@"simple-to-json.xsl"];
	CYTemplate *tmpl = [CYTemplate templateWithData:xsltData];
	CYDataInputSource *xml = [[CYDataInputSource alloc] initWithData:[@"<passage><para>Hello, world.</para><para>Hi, world.</para></passage>" dataUsingEncoding:NSUTF8StringEncoding]
															 options:CYParsingDefaultOptions];
	
	NSError *error = nil;
	NSString *result = [tmpl transformToString:xml parameters:nil error:&error];
	assertThat(error, nilValue());
	NSString *expected = @"{\"paras\":[\"Hello, world.\",\"Hi, world.\"]}";
	assertThat(result, equalTo(expected));
}

- (void)testTransformFileJSON {
	NSString *xsltFile = [self pathForTestXSLResource:@"simple-to-json.xsl"];
	CYTemplate *tmpl = [CYTemplate templateWithContentsOfFile:xsltFile];
	NSString *xmlFile = [self pathForTestXSLResource:@"simple-to-json.xml"];
	CYFileInputSource *xml = [[CYFileInputSource alloc] initWithContentsOfFile:xmlFile options:CYParsingDefaultOptions];
	
	NSError *error = nil;
	NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"simple-to-json.json"];
	[[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
	[tmpl transform:xml parameters:nil toFile:outPath error:&error];
	XCTAssertNil(error);
	NSString *result = [NSString stringWithContentsOfFile:outPath encoding:NSUTF8StringEncoding error:nil];
	NSString *expected = @"{\"paras\":[\"Hello, world.\",\"Hi, world.\"]}";
	assertThat(result, equalTo(expected));
}

- (void)testTransformWithParamsPerformanceFirstTransform {
	__block NSData *xsltData = [self testXSLDataForResource:@"params-to-html.xsl"];
	CYDataInputSource *xml = [[CYDataInputSource alloc] initWithData:[@"<passage><para>Hello, world.</para></passage>" dataUsingEncoding:NSUTF8StringEncoding]
															 options:CYParsingAsHTML];
	NSDictionary<NSString *, id> *params = @{@"strength" : @98.9, @"prowess" : @"unparalleled"};
	[self measureBlock:^{
		CYTemplate *tmpl = [CYTemplate templateWithData:xsltData];
		@autoreleasepool {
			NSError *error = nil;
			NSString *result = [tmpl transformToString:xml parameters:params error:&error];
			assertThat(error, nilValue());
			assertThat(result, notNilValue());
		}
	}];
}

- (void)testTransformWithParamsPerformanceRepeatTransforms {
	__block NSData *xsltData = [self testXSLDataForResource:@"params-to-html.xsl"];
	CYDataInputSource *xml = [[CYDataInputSource alloc] initWithData:[@"<passage><para>Hello, world.</para></passage>" dataUsingEncoding:NSUTF8StringEncoding]
															 options:CYParsingAsHTML];
	NSDictionary<NSString *, id> *params = @{@"strength" : @98.9, @"prowess" : @"unparalleled"};
	[self measureBlock:^{
		CYTemplate *tmpl = [CYTemplate templateWithData:xsltData];
		for ( int i = 0; i < 1000; i++ ) {
			@autoreleasepool {
				NSError *error = nil;
				NSString *result = [tmpl transformToString:xml parameters:params error:&error];
				assertThat(error, nilValue());
				assertThat(result, notNilValue());
			}
		}
	}];
}

- (void)testReadmeExample {
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
	assertThat(result, equalTo(@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
							   @"<output><msg>Hello, BRCybertron.</msg><msg>More than meets the eye!</msg></output>\n"));
}

@end
