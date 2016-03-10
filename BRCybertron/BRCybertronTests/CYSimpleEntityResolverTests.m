//
//  CYSimpleEntityResolverTests.m
//  BRCybertron
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "CYDataInputSource.h"
#import "CYParsingContext.h"
#import "CYSimpleEntityResolver.h"

@interface CYSimpleEntityResolverTests : XCTestCase

@end

@implementation CYSimpleEntityResolverTests

- (void)testResolveInternal {
	CYSimpleEntityResolver *resolver = [[CYSimpleEntityResolver alloc] init];
	[resolver addInternalEntities:@{@"foo" : @"bar", @"bim" : @"bam"}];
	
	CYDataInputSource *input = [[CYDataInputSource alloc] initWithData:[@"<x/>" dataUsingEncoding:NSUTF8StringEncoding] options:0];
	CYParsingContext *context = [[CYParsingContext alloc] initWithInputSource:input];
	
	id<CYEntity> ent;
	
	ent = [resolver resolveEntity:@"foo" context:context];
	assertThat(ent.name, equalTo(@"foo"));
	assertThat(ent.content, equalTo(@"bar"));
	
	ent = [resolver resolveEntity:@"bim" context:context];
	assertThat(ent.name, equalTo(@"bim"));
	assertThat(ent.content, equalTo(@"bam"));
	
	ent = [resolver resolveEntity:@"megatron" context:context];
	assertThat(ent, nilValue());
}

- (void)testResetInternal {
	CYSimpleEntityResolver *resolver = [[CYSimpleEntityResolver alloc] init];
	[resolver addInternalEntities:@{@"foo" : @"bar"}];
	
	CYDataInputSource *input = [[CYDataInputSource alloc] initWithData:[@"<x/>" dataUsingEncoding:NSUTF8StringEncoding] options:0];
	CYParsingContext *context = [[CYParsingContext alloc] initWithInputSource:input];
	
	id<CYEntity> ent;
	
	ent = [resolver resolveEntity:@"foo" context:context];
	assertThat(ent.name, equalTo(@"foo"));
	assertThat(ent.content, equalTo(@"bar"));
	
	[resolver setInternalEntities:nil];
	
	ent = [resolver resolveEntity:@"foo" context:context];
	assertThat(ent, nilValue());
}

@end
