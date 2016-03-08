//
//  ParameterTableViewCell.m
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "ParameterTableViewCell.h"

@interface ParameterTableViewCell ()
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *valueField;
@end

@implementation ParameterTableViewCell

- (void)setName:(NSString *)name {
	self.nameField.text = name;
}

- (NSString *)name {
	return self.nameField.text;
}

- (void)setValue:(NSString *)value {
	self.valueField.text = value;
}

- (NSString *)value {
	return self.valueField.text;
}

@end
