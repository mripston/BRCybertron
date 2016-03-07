//
//  ViewController.m
//  CreationMatrix
//
//  Created by Matt on 7/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "ViewController.h"

#import <BRCybertron/BRCybertron.h>
#import <JSONSyntaxHighlight/JSONSyntaxHighlight.h>

#import "FileChooserTableViewController.h"

@interface ViewController () <UITextFieldDelegate, FileChooserTableViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *inputFileTextField;
@property (strong, nonatomic) IBOutlet UITextField *xslFileTextField;
@property (strong, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ViewController {
	UITextField *chooserField;
	NSString *xslPath;
	NSString *xmlPath;
	CYFileInputSource *xml;
	CYTemplate *xslt;
	NSError *error;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:@"ShowFileChooser"] ) {
		FileChooserTableViewController *dest = segue.destinationViewController;
		dest.fileExtensionFilter = (chooserField == self.xslFileTextField ? @"xsl" : @"xml");
		dest.chooserDelegate = self;
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	chooserField = textField;
	[self performSegueWithIdentifier:@"ShowFileChooser" sender:self];
	return NO;
}

- (void)chooser:(FileChooserTableViewController *)controller didSelectFile:(NSString *)path {
	if ( chooserField == self.xslFileTextField ) {
		self.xslFileTextField.text = [path lastPathComponent];
		xslPath = path;
		xslt = [CYTemplate templateWithContentsOfFile:path];
	} else {
		self.inputFileTextField.text = [path lastPathComponent];
		xmlPath = path;
		xml = [[CYFileInputSource alloc] initWithContentsOfFile:path options:CYParsingDefaultOptions]; // TODO: toggle for HTML
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *err = nil;
		CYTemplate *t = xslt;
		CYFileInputSource *x = xml;
		if ( x && t ) {
			NSString *result = [t transformToString:x parameters:nil error:&err];
			NSAttributedString *attributedResult = nil;
			error = err;
			if ( [[xslPath lastPathComponent] containsString:@"to-json"] ) {
				NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
				id json = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
				JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:json];
				NSAttributedString *highlighted = [jsh highlightJSONWithPrettyPrint:YES];
				if ( highlighted ) {
					attributedResult = highlighted;
				}
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				if ( attributedResult ) {
					self.resultTextView.attributedText = attributedResult;
				} else {
					self.resultTextView.text = result;
				}
				if ( err ) {
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleActionSheet];
					[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
					[self presentViewController:alert animated:YES completion:nil];
				}
			});
		}
	});
	[self.navigationController popToViewController:self animated:YES];
}

@end
