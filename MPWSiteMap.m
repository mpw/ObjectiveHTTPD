//
//  MPWSiteMap.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWSiteMap.h"
#import "WAHtmlRenderer.h"
#import "MPWHtmlPage.h"
#import "MPWTemplater.h"
#import "MPWHTMLRenderScheme.h"

@implementation MPWSiteMap



+sharedSite
{
	static id site=nil;
	if ( !site ) {
		site=[self alloc];
		site=[site init];
	}
	return site;
}
@end

@implementation MPWSiteMap(testing)

+_configuredSite
{
	id site=[[[self alloc] init] autorelease];
    MPWTemplater* templater=[[[MPWTemplater alloc] init] autorelease];
    id template = [[[MPWHtmlPage alloc] init] autorelease];
    NSLog(@"templater: %@ template: %@",templater,template);
    [templater setTemplate:template];
    [templater setSourceScheme:site];
    id renderer = [[[MPWHTMLRenderScheme alloc] init] autorelease];
    [renderer setSourceScheme:templater];
    return renderer;
}

+(void)testPlainPage
{
    id templater=[self _configuredSite];
	id result = [[templater get:@"index.html"] stringValue];
	IDEXPECT( result, @"<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"></meta><title></title></head><body></body></html>", @"html for index.html");
	result = [[templater get:@"index.html"] stringValue];
	IDEXPECT( result, @"<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"></meta><title></title></head><body></body></html>", @"html for index.html second time");
}

+(void)testPlainPageWithTitle
{
    id templater=[self _configuredSite];
	id result = [[templater get:@"index.html"] stringValue];
	IDEXPECT( result, @"<html><head><title></title>\n</head>\n<body></body>\n</html>\n", @"html for index.html");
}


+testSelectors {
	return [NSArray arrayWithObjects:
            @"testPlainPage",
		nil];
}

@end
