//
//  MPWSiteMap.m
//  MPWSideweb
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWSiteMap.h"
#import "WAHtmlRenderer.h"
#import "MPWHtmlPage.h"
#import "MPWTreeNode.h"
#import <MPWTalk/MPWGenericBinding.h>
#import "MPWTemplater.h"
#import "MPWHTMLRenderScheme.h"

@implementation MPWSiteMap

idAccessor( root, setRoot )

+sharedSite
{
	static id site=nil;
	if ( !site ) {
		site=[self alloc];
		site=[site init];
	}
	return site;
}

-init
{
	self = [super init];
	[self setRoot:[MPWTreeNode root]];
	NSLog(@"init %@ root: %@",self,root);
	return self;
}

-contentForPath:(NSArray*)array
{
	return [root nodeForPathEnumerator:[array objectEnumerator]];
}


-(void)setValue:newValue forBinding:(MPWGenericBinding*)aBinding
{
    
}


-(void)dealloc
{
	[root release];
	[super dealloc];
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
	IDEXPECT( result, @"<html><head><title></title></head><body></body></html>", @"html for index.html");
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
