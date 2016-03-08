//
//  FileChooserTableViewController.h
//  CreationMatrix
//
//  Created by Matt on 7/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import <UIKit/UIKit.h>

@protocol FileChooserTableViewControllerDelegate;

@interface FileChooserTableViewController : UITableViewController

@property (nonatomic, weak) id<FileChooserTableViewControllerDelegate> chooserDelegate;
@property (nonatomic, strong) NSString *fileExtensionFilter;

/**
 The directory within the main bundle the app looks for XML and XSL files.
 
 @return The directory path.
 */
+ (NSString *)resourceDir;

@end

@protocol FileChooserTableViewControllerDelegate <NSObject>

- (void)chooser:(FileChooserTableViewController *)controller didSelectFile:(NSString *)path;

@end
