//
//  CYDataInputSource.h
//  BRCybertron
//
//  Created by Matt on 5/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "CYInputSourceSupport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An input source to read from a @c NSData instance.
 */
@interface CYDataInputSource : CYInputSourceSupport

/**
 Initialize from a NSData instance.
 
 @param data    The XML resource.
 @param options The parsing options.
 
 @return The initialized instance.
 */
- (instancetype)initWithData:(NSData *)theData options:(CYParsingOptions)options NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
