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
#import "ParametersTableViewController.h"

static NSString * const kEditParametersSegue = @"EditParameters";
static NSString * const kShowFileChooserSegue = @"ShowFileChooser";

@interface ViewController () <UITextFieldDelegate, FileChooserTableViewControllerDelegate, ParametersViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *inputFileTextField;
@property (strong, nonatomic) IBOutlet UITextField *xslFileTextField;
@property (strong, nonatomic) IBOutlet UITextView *resultTextView;
@property (strong, nonatomic) IBOutlet UITextField *repeatTextField;
@property (strong, nonatomic) IBOutlet UIButton *executeButton;
@property (strong, nonatomic) IBOutlet UIButton *paramsButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation ViewController {
	UITextField *chooserField;
	NSString *xslPath;
	NSString *xmlPath;
	NSDictionary<NSString *,NSString *> *parameters;
	CYFileInputSource *xml;
	CYTemplate *xslt;
	NSError *error;
	BOOL haveResources;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ( xslPath == nil && xmlPath == nil ) {
		// populate the first available XML/XSL if we can
		NSString *dir = [FileChooserTableViewController resourceDir];
		NSArray<NSString *> *resources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
		for ( NSString *name in resources ) {
			if ( xmlPath == nil && [[name pathExtension] isEqualToString:@"xml"] ) {
				[self setXmlPath:[dir stringByAppendingPathComponent:name]];
			} else if ( xslPath == nil && [[name pathExtension] isEqualToString:@"xsl"] ) {
				[self setXslPath:[dir stringByAppendingPathComponent:name]];
			}
			if ( xmlPath && xslPath ) {
				haveResources = YES;
				break;
			}
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ( haveResources == NO ) {
		NSString *msg = @"Place XML input files and XSL template files to test in the “MatrixResources” directory and re-deploy the app. "
			@"If any XSL file name contains “to-json” the results will be assumed to be JSON and will have syntax highlighting applied.";
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)setXslPath:(NSString *)path {
	self.xslFileTextField.text = [path lastPathComponent];
	xslPath = path;
	xslt = [CYTemplate templateWithContentsOfFile:path];
}

- (void)setXmlPath:(NSString *)path {
	self.inputFileTextField.text = [path lastPathComponent];
	xmlPath = path;
	xml = [[CYFileInputSource alloc] initWithContentsOfFile:path options:CYParsingDefaultOptions]; // TODO: toggle for HTML
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:kShowFileChooserSegue] ) {
		FileChooserTableViewController *dest = segue.destinationViewController;
		dest.fileExtensionFilter = (chooserField == self.xslFileTextField ? @"xsl" : @"xml");
		dest.chooserDelegate = self;
	} else if ( [segue.identifier isEqualToString:kEditParametersSegue] ) {
		UINavigationController *nav = segue.destinationViewController;
		ParametersTableViewController *dest = (ParametersTableViewController *)nav.topViewController;
		dest.parametersDelegate = self;
		dest.parameters = parameters;
	}
}

- (IBAction)execute:(id)sender {
	CYTemplate *t = xslt;
	CYFileInputSource *x = xml;
	const int count = ([self.repeatTextField.text intValue] ? [self.repeatTextField.text intValue] : 1);
	if ( !(x && t) ) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please choose both XML and XSL files." preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
		return;
	}
	self.executeButton.enabled = NO;
	self.statusLabel.text = [NSString stringWithFormat:@"Executing %d transforms...", count];
	[self.view endEditing:YES];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *result = nil;
		NSError *err = nil;
		NSTimeInterval currTime = 0;
		NSTimeInterval firstTime = 0;
		NSTimeInterval totalTime = 0;
		
		[NSThread sleepForTimeInterval:1]; // give the main thread time to settle down
		
		NSTimeInterval sTime;
		for ( int i = 0; i < count; i++ ) {
			@autoreleasepool {
				sTime = [NSDate timeIntervalSinceReferenceDate];
				result = [t transformToString:x parameters:parameters error:&err];
				currTime = [NSDate timeIntervalSinceReferenceDate] - sTime;
			}
			if ( i == 0 ) {
				firstTime = currTime;
			}
			totalTime += currTime;
			if ( err ) {
				break;
			}
		}
		
		NSAttributedString *attributedResult = nil;
		error = err;
		if ( [[xslPath lastPathComponent] rangeOfString:@"to-json"].location != NSNotFound ) {
			NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
			id json = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
			JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:json];
			NSAttributedString *highlighted = [jsh highlightJSONWithPrettyPrint:YES];
			if ( highlighted ) {
				attributedResult = highlighted;
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.text = [NSString stringWithFormat:@"Avg: %.0fms, first %.0fms, count %d",
									 ((totalTime / count) * 1000.0),
									 (firstTime * 1000.0), count];
			if ( attributedResult ) {
				self.resultTextView.attributedText = attributedResult;
			} else {
				self.resultTextView.text = result;
			}
			self.executeButton.enabled = YES;
			if ( err ) {
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
				[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
				[self presentViewController:alert animated:YES completion:nil];
			}
		});
	});
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	chooserField = textField;
	[self performSegueWithIdentifier:kShowFileChooserSegue sender:self];
	return NO;
}

- (void)chooser:(FileChooserTableViewController *)controller didSelectFile:(NSString *)path {
	if ( chooserField == self.xslFileTextField ) {
		[self setXslPath:path];
	} else {
		[self setXmlPath:path];
	}
	[self.navigationController popToViewController:self animated:YES];
}

- (void)parametersController:(ParametersTableViewController *)controller didUpdateParameters:(NSDictionary<NSString *,NSString *> *)params {
	parameters = params;
	self.paramsButton.selected = (params.count > 1);
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
