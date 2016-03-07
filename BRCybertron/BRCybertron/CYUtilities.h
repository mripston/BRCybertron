//
//  CYUtilities.h
//  BRCybertron
//
//  Created by Matt on 6/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Utilities to help with XML/XSLT handling.
 */
@interface CYUtilities : NSObject

/**
 Execute a block on the calling thead followed by a callback block with any errors captured from @c libxml during 
 the executino of the block.
 
 @param block    The block that exercises libxml functions and might generate errors in the process.
 @param callback A block that will be invoked after the completion of @c block, with an array of errors or @c nil if no errors were generated.
 */
+ (void)captureParsingErrors:(void (^)(void))block finished:(void (^)(NSArray<NSError *> * _Nullable errors))callback;

@end

NS_ASSUME_NONNULL_END
