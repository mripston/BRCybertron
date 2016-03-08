//
//  ParametersTableViewController.m
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "ParametersTableViewController.h"

#import "ParameterTableViewCell.h"

@interface ParametersTableViewController () <ParameterTableViewCellDelegate>

@end

@implementation ParametersTableViewController {
	NSMutableDictionary<NSString *, NSString *> *parameters;
	NSMutableArray<NSString *> *keys;
}

@synthesize parameters;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ( !parameters ) {
		parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	if ( !keys ) {
		keys = [[NSMutableArray alloc] initWithCapacity:4];
	}
}

- (void)setParameters:(NSDictionary<NSString *,NSString *> *)params {
	keys = [[[params allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
	if ( !keys ) {
		keys = [[NSMutableArray alloc] initWithCapacity:4];
	}
	parameters = [params mutableCopy];
	if ( !parameters ) {
		parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
}

- (IBAction)addNewParameter:(id)sender {
	[keys insertObject:@"" atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)done:(id)sender {
	[self.parametersDelegate parametersController:self didUpdateParameters:[parameters copy]];
}

- (void)parameterCellDidChange:(ParameterTableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	NSString *newKey = cell.name;
	NSString *newVal = cell.value;
	NSString *oldKey = keys[indexPath.row];
	if ( [oldKey isEqualToString:newKey] == NO ) {
		[parameters removeObjectForKey:oldKey];
		[keys replaceObjectAtIndex:indexPath.row withObject:newKey];
	}
	parameters[newKey] = newVal;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParameterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParamCell" forIndexPath:indexPath];
	cell.name = keys[indexPath.row];
	cell.value = parameters[keys[indexPath.row]];
	cell.parameterDelegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
		[keys removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }   
}

@end
