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

-renderer
{
	return [WAHtmlRenderer stream];
}

-contentForURI:uri
{
	return [root nodeForPath:uri];
}


-pageForContentNode:aNode
{
	return [[[MPWHtmlPage alloc] init] autorelease];
}

-(NSData*)binaryDataForContentNode:aNode
{
	id renderer = [self renderer];
	id page=[self pageForContentNode:aNode];
	[page setContent:aNode];
	[renderer writeObject:page];
	return [renderer result];
}

-(NSData*)binaryDataForURI:uri
{
	return [self binaryDataForContentNode:[self contentForURI:uri]];
}

-(NSData*)htmlPageForURI:uri
{
	return [self binaryDataForURI:uri];
}

-(void)dealloc
{
	[root release];
	[super dealloc];
}

@end

@implementation MPWSiteMap(testing)


+(void)testPlainPage
{
	id site=[[[self alloc] init] autorelease];
	id result = [[site htmlPageForURI:@"index.html"] stringValue];
	IDEXPECT( result, @"<html><head><title></title></head><body></body></html>", @"html for index.html");
}

+(void)testPlainPageWithTitle
{
	id site=[[[self alloc] init] autorelease];
	id result = [[site htmlPageForURI:@"index.html"] stringValue];
	IDEXPECT( result, @"<html><head><title></title>\n</head>\n<body></body>\n</html>\n", @"html for index.html");
}

+testSelectors {
	return [NSArray arrayWithObjects:
		@"testPlainPage",
		nil];
}

@end
