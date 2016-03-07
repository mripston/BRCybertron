//
//  CYFileInputSourceTests.m
//  BRCybertron
//
//  Created by Matt on 7/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <libxml/parser.h>
#import "CYFileInputSource.h"

@interface CYFileInputSourceTests : XCTestCase

@end

@implementation CYFileInputSourceTests

- (NSString *)pathForTestXSLResource:(NSString *)name {
	return [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:nil inDirectory:@"TestResources"];
}

- (void)testParseSimpleFile {
	NSString *path = [self pathForTestXSLResource:@"params-to-html.xml"];
	CYFileInputSource *input = [[CYFileInputSource alloc] initWithContentsOfFile:path options:0];
	
	NSError *error = nil;
	xmlDocPtr doc = [input getDocument:&error];
	XCTAssertNil(error);
	XCTAssertTrue(doc != NULL);
}

- (void)testToStringSimpleNoFormat {
	NSString *path = [self pathForTestXSLResource:@"params-to-html.xml"];
	CYFileInputSource *input = [[CYFileInputSource alloc] initWithContentsOfFile:path options:0];
	
	NSError *error = nil;
	NSString *result = [input asString:NO error:&error];
	XCTAssertNil(error);
	
	NSString *expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
						@"<passage><para>Hello, world.</para></passage>\n";
	XCTAssertEqualObjects(expected, result);
}

- (void)testToStringSimpleFormat {
	NSString *path = [self pathForTestXSLResource:@"params-to-html.xml"];
	CYFileInputSource *input = [[CYFileInputSource alloc] initWithContentsOfFile:path options:0];
	
	NSError *error = nil;
	NSString *result = [input asString:YES error:&error];
	XCTAssertNil(error);
	
	NSString *expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
						@"<passage>\n  <para>Hello, world.</para>\n</passage>\n";
	XCTAssertEqualObjects(expected, result);
}

@end
