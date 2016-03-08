//
//  CYTemplate.m
//  BRCybertron
//
//  Created by Matt on 4/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the MIT License.
//

#import "CYTemplate.h"

#import <libxml/parser.h>
#import <libxslt/transform.h>
#import <libxslt/xsltInternals.h>
#import <libxslt/xsltutils.h>
#import "CYDataInputSource.h"
#import "CYFileInputSource.h"

@implementation CYTemplate {
	id<CYInputSource> xsltInputSource;
	xsltStylesheetPtr xslt;
	NSError *parsingError;
}

- (instancetype)init {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	return [self initWithInputSource:nil];
#pragma clang diagnostic pop
}

- (instancetype)initWithInputSource:(id<CYInputSource>)theXsltInputSource {
	if ( (self = [super init]) ) {
		xsltInputSource = theXsltInputSource;
	}
	return self;
}

- (void)dealloc {
	if ( xslt != NULL ) {
		xsltFreeStylesheet(xslt);
	}
}

+ (instancetype)templateWithContentsOfFile:(NSString *)filePath {
	CYFileInputSource *input = [[CYFileInputSource alloc] initWithContentsOfFile:filePath options:CYParsingDefaultOptions];
	return [[self alloc] initWithInputSource:input];
}

+ (instancetype)templateWithData:(NSData *)data {
	CYDataInputSource *input = [[CYDataInputSource alloc] initWithData:data options:CYParsingDefaultOptions];
	return [[self alloc] initWithInputSource:input];
}

- (nullable xsltStylesheetPtr)newStylesheetFromInputSource:(id<CYInputSource>)inputSource error:(NSError **)error {
	xmlDocPtr doc = NULL;
	xsltStylesheetPtr result = NULL;
	
	doc = [inputSource newDocument:error];
	
	if ( doc != NULL ) {
		// NOTE: xsltParseStylesheetDoc takes ownership of the passed in doc, so we do NOT free it here!
		result = xsltParseStylesheetDoc(doc);
		if ( result == NULL ) {
			// TODO: error result
		}
	}
	
	return result;
}

- (xsltStylesheetPtr)xsltStylesheet {
	if ( xslt ) {
		return xslt;
	}
	NSError *error = nil;
	xslt = [self newStylesheetFromInputSource:xsltInputSource error:&error];
	parsingError = error;
	return xslt;
}

/**
 Convert plain number and string objects into a form suitable for passing into libxslt as input parameters.
 Note the returned array of strings must be freed by the called, however the individual strings within the
 array will be freed when the @c xpathParameters values are released (i.e. don't free them manually!).
 
 @param parameters      The parameters to convert.
 @param xpathParameters A mutable array to hold the converted string values.
 
 @return A newly allocated array of strings.
 */
- (const char **)convertParameters:(nullable NSDictionary<NSString *, id> *)parameters toXSLTForm:(nullable NSMutableDictionary<NSString *, NSString *> *)xpathParameters {
	const char **params = NULL;
	if ( parameters.count > 0 ) {
		// construct parameters as array of string keys and values, with NULL terminating element
		params = malloc((parameters.count * 2 + 1) * sizeof(char *));
		__block NSUInteger idx = 0;
		[parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
			params[idx++] = [key UTF8String];
			
			// convert value into XPath, which means escaping strings or turning numbers into strings
			NSString *xpath;
			if ( [obj isKindOfClass:[NSNumber class]] ) {
				xpath = [(NSNumber *)obj descriptionWithLocale:nil];
			} else {
				xpath = [NSString stringWithFormat:@"'%@'", [[obj description] stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]];
			}
			if ( xpathParameters ) {
				xpathParameters[key] = xpath;
			}
			params[idx++] = [xpath UTF8String];
		}];
		params[idx] = NULL;
	}
	return params;
}

- (NSString *)transformToString:(id<CYInputSource>)input parameters:(nullable NSDictionary<NSString *, id> *)parameters error:(NSError **)error {
	xmlDocPtr inputDocument = [input getDocument:error];
	if ( inputDocument == NULL ) {
		return nil;
	}
	
	NSMutableDictionary *xpathParameters = [parameters mutableCopy]; // to keep XPath converted values in memory during transform
	const char **params = [self convertParameters:parameters toXSLTForm:xpathParameters];
	
	xmlDocPtr outputDocument = NULL;
	xsltTransformContextPtr ctxt = NULL;
	xsltStylesheetPtr xform = [self xsltStylesheet];
	if ( xform == NULL ) {
		if ( error && parsingError ) {
			*error = parsingError;
		}
	} else {
		ctxt = xsltNewTransformContext(xform, inputDocument);
		// TODO: xsltSetCtxtParseOptions(ctxt, options);
		outputDocument = xsltApplyStylesheetUser(xform, inputDocument, params, NULL, NULL, ctxt);
	}
	
	xmlChar *output = NULL;
	int outputLength = 0;
	if ( outputDocument ) {
		xsltSaveResultToString(&output, &outputLength, outputDocument, xform);
	}
	
	if ( params != NULL ) {
		free(params);
	}
	xpathParameters = nil;
	
	NSString *result = nil;
	if ( output != NULL ) {
		result = [NSString stringWithUTF8String:(char *)output];
		xmlFree(output);
	}
	if ( outputDocument != NULL ) {
		xmlFreeDoc(outputDocument);
	}
	if ( ctxt != NULL ) {
		xsltFreeTransformContext(ctxt);
	}
	
	return result;
}

- (void)transform:(id<CYInputSource>)input
	   parameters:(NSDictionary<NSString *,id> *)parameters
		   toFile:(NSString *)filePath
			error:(NSError * _Nullable __autoreleasing *)error {
	xmlDocPtr inputDocument = [input getDocument:error];
	if ( inputDocument == NULL ) {
		return;
	}
	
	NSMutableDictionary *xpathParameters = [parameters mutableCopy]; // to keep XPath converted values in memory during transform
	const char **params = [self convertParameters:parameters toXSLTForm:xpathParameters];
	
	xmlDocPtr outputDocument = NULL;
	xsltTransformContextPtr ctxt = NULL;
	xsltStylesheetPtr xform = [self xsltStylesheet];
	if ( xform == NULL ) {
		if ( error && parsingError ) {
			*error = parsingError;
		}
	} else {
		ctxt = xsltNewTransformContext(xform, inputDocument);
		// TODO: xsltSetCtxtParseOptions(ctxt, options);
		outputDocument = xsltApplyStylesheetUser(xform, inputDocument, params, NULL, NULL, ctxt);
	}
	
	xsltSaveResultToFilename([filePath UTF8String], outputDocument, xform, 0);
	
	if ( params != NULL ) {
		free(params);
	}
	xpathParameters = nil;
	
	if ( outputDocument != NULL ) {
		xmlFreeDoc(outputDocument);
	}
	if ( ctxt != NULL ) {
		xsltFreeTransformContext(ctxt);
	}
}

@end
