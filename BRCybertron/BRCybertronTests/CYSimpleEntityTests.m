//
//  CYSimpleEntityTests.m
//  BRCybertron
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
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

@end
