//
//  ParameterTableViewCell.m
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "ParameterTableViewCell.h"

@interface ParameterTableViewCell () <UITextFieldDelegate>
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

- (void)informDelegateOfChange {
	[self.parameterDelegate parameterCellDidChange:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[ParameterTableViewCell cancelPreviousPerformRequestsWithTarget:self selector:@selector(informDelegateOfChange) object:nil];
	[self performSelector:@selector(informDelegateOfChange) withObject:nil afterDelay:0.3];
	return YES;
}

@end
