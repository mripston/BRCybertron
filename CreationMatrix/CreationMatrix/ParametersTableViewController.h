//
//  ParametersTableViewController.h
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <UIKit/UIKit.h>

@protocol ParametersViewControllerDelegate;

@interface ParametersTableViewController : UITableViewController

@property (nonatomic, weak) id<ParametersViewControllerDelegate> parametersDelegate;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *parameters;

@end

@protocol ParametersViewControllerDelegate <NSObject>

/**
 Callback when the parameters have been updated.
 
 @param controller The controller managing the update.
 @param parameters The updated parameters.
 */
- (void)parametersController:(ParametersTableViewController *)controller
		 didUpdateParameters:(NSDictionary<NSString *, NSString *> *)parameters;

@end
