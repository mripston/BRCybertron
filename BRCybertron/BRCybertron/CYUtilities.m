//
//  CYUtilities.m
//  BRCybertron
//
//  Created by Matt on 6/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "CYUtilities.h"

#import <libxml/parser.h>
#import "CYConstants.h"
#import "CYInputSource.h"

static NSString * const kParsingErrorsThreadKey = @"CYDataInputSource.Errors";

static void xmlStructuredErrorHandler(void *context, xmlErrorPtr error);

@implementation CYUtilities

+ (void)captureParsingErrors:(void (^)(void))block finished:(void (^)(NSArray<NSError *> * _Nullable errors))callback {
	[[NSThread currentThread].threadDictionary removeObjectForKey:kParsingErrorsThreadKey];
	xmlSetStructuredErrorFunc(NULL, &xmlStructuredErrorHandler);
	@try {
		if ( block ) {
			block();
		}
	}
	@finally {
		NSArray<NSError *> *errors = [NSThread currentThread].threadDictionary[kParsingErrorsThreadKey];
		if ( callback ) {
			callback(errors);
		}
		[[NSThread currentThread].threadDictionary removeObjectForKey:kParsingErrorsThreadKey];
	}
}

@end

static void xmlStructuredErrorHandler(void *context, xmlErrorPtr error) {
	NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:8];
	NSString *msg = nil;
	if ( strlen(error->message) > 0 ) {
		msg = [[NSString alloc] initWithCString:error->message encoding:NSUTF8StringEncoding];
	}
	int xmlDomain = error->domain;
	int xmlCode = error->code;
	int line = error->line;
	int col = error->int2;
	if ( strlen(error->message) > 0 ) {
		msg = [[NSString alloc] initWithCString:error->message encoding:NSUTF8StringEncoding];
	}
	if ( msg ) {
		info[NSLocalizedDescriptionKey] = msg;
	}
	if ( line ) {
		info[@"line"] = @(line);
	}
	if ( col ) {
		info[@"column"] = @(col);
	}
	if ( xmlDomain ) {
		info[@"libxmlDomain"] = @(xmlDomain);
	}
	if ( xmlCode ) {
		info[@"libxmlCode"] = @(xmlCode);
	}
	NSMutableArray *errors = [NSThread currentThread].threadDictionary[kParsingErrorsThreadKey];
	if ( !errors ) {
		errors = [[NSMutableArray alloc] initWithCapacity:2];
		[NSThread currentThread].threadDictionary[kParsingErrorsThreadKey] = errors;
	}
	[errors addObject:[NSError errorWithDomain:CYErrorDomain code:CYParsingErrorParsingFailed userInfo:info]];
}
