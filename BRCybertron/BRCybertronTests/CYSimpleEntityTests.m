//
//  CYSimpleEntityTests.m
//  BRCybertron
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "CYSimpleEntity.h"

@interface CYSimpleEntityTests : XCTestCase

@end

@implementation CYSimpleEntityTests

- (void)testInit {
	CYSimpleEntity *ent = [[CYSimpleEntity alloc] initWithName:@"foo" content:@"bar"];
	assertThat(ent.name, equalTo(@"foo"));
	assertThat(ent.content, equalTo(@"bar"));
	assertThat(ent.externalID, nilValue());
	assertThat(ent.systemID, nilValue());
}

- (void)testGetXmlEntity {
	CYSimpleEntity *ent = [[CYSimpleEntity alloc] initWithName:@"foo" content:@"bar"];
	
	NSError *error = nil;
	xmlEntityPtr xmlEnt = [ent getEntity:&error];
	assertThat(error, nilValue());
	XCTAssertTrue(xmlEnt != NULL);
}

@end
