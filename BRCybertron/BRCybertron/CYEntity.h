//
//  CYEntity.h
//  BRCybertron
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 API for an entity declaration.
 */
@protocol CYEntity <NSObject>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, nullable) NSString *externalID;
@property (nonatomic, readonly, nullable) NSString *systemID;
@property (nonatomic, readonly) NSString *content;

@end

NS_ASSUME_NONNULL_END
