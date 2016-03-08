//
//  CYSimpleEntity.m
//  BRCybertron
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "CYSimpleEntity.h"

@implementation CYSimpleEntity {
	NSString *name;
	NSString *content;
	NSString *externalID;
	NSString *systemID;
}

@synthesize name;
@synthesize content;
@synthesize systemID;
@synthesize externalID;

- (instancetype)init {
	return [self initWithName:@"" content:@""];
}

- (instancetype)initWithName:(NSString *)theName content:(NSString *)theContent {
	if ( (self = [super init]) ) {
		name = theName;
		content = theContent;
	}
	return self;
}

@end
