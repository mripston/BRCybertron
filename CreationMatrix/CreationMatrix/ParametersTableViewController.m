//
//  ParametersTableViewController.m
//  CreationMatrix
//
//  Created by Matt on 8/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "ParametersTableViewController.h"

#import "ParameterTableViewCell.h"

@interface ParametersTableViewController ()

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
	if ( parameters[@""] == nil ) {
		[keys insertObject:@"" atIndex:0];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (IBAction)done:(id)sender {
	// TODO: delegate callback
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
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
