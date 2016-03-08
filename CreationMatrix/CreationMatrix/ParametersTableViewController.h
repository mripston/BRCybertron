//
//  ParametersTableViewController.h
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <UIKit/UIKit.h>

@interface ParametersTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *parameters;

@end
