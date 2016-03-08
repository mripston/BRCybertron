//
//  ParameterTableViewCell.h
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <UIKit/UIKit.h>

@protocol ParameterTableViewCellDelegate;

@interface ParameterTableViewCell : UITableViewCell

@property (nonatomic, weak) id<ParameterTableViewCellDelegate> parameterDelegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;

@end

@protocol ParameterTableViewCellDelegate <NSObject>

/**
 Notify the receiver that the name or value have changed.
 
 @param cell The cell whose parameter value has changed.
 */
- (void)parameterCellDidChange:(ParameterTableViewCell *)cell;

@end
