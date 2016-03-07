//
//  FileChooserTableViewController.m
//  CreationMatrix
//
//  Created by Matt on 7/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "FileChooserTableViewController.h"

@interface FileChooserTableViewController ()

@end

@implementation FileChooserTableViewController {
	UITextField *chooserField;
	NSArray<NSString *> *files;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
}

- (NSString *)resourceDir {
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MatrixResources"];
}

- (NSArray<NSString *> *)filteredFiles {
	if ( files ) {
		return files;
	}
	NSArray<NSString *> *resources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self resourceDir] error:nil];
	resources = [resources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", self.fileExtensionFilter]];
	files = resources;
	return resources;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self filteredFiles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
	cell.textLabel.text = files[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *file = [[self resourceDir] stringByAppendingPathComponent:files[indexPath.row]];
	[self.chooserDelegate chooser:self didSelectFile:file];
}

@end
