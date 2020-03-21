//
//  MPWHtmlPage.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWHtmlPage.h"
#import "WAHtmlRenderer.h"

@implementation MPWHtmlPage

idAccessor( title, setTitle )
idAccessor( content , setContent )
idAccessor( path , setPath )

-init
{
	[super init];
	[self setTitle:@""];
	return self;
}

-(void)renderHeaderOn:(WAHtmlRenderer*)aRenderer
{
    [aRenderer element:"meta" attributes:@"http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"" content:@""];
	[aRenderer element:"title" content:[self title]];
}

-(void)renderBodyOn:(WAHtmlRenderer*)aRenderer
{
	if ( [self content] ) {
		[aRenderer element:"div" attributes:@" name='mainContent'"  content:[self content]];
	}
}

-(void)renderHtmlOn:(WAHtmlRenderer*)renderer
{
	[renderer element:"head" content:self selector:@selector(renderHeaderOn:)];
	[renderer element:"body" content:self selector:@selector(renderBodyOn:)];
}

-(void)renderOn:(WAHtmlRenderer*)renderer
{
	[renderer element:"html" content:self selector:@selector(renderHtmlOn:)];
}


-(void)dealloc
{
	[content release];
	[title release];
    [path release];
	[super dealloc];
}

@end

#import "WAHtmlRenderer.h"

@implementation MPWHtmlPage(rendering)



+(void)testPlainPage
{
	id page=[[[self alloc] init] autorelease];
	id result=[[WAHtmlRenderer process:page] stringValue];
	IDEXPECT( result, @"<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"></meta><title></title></head><body></body></html>", @"html for index.html");
}

+(void)testPlainPageWithTitle
{
	id page=[[[self alloc] init] autorelease];
	id result;
	[page setTitle:@"Test Title"];
	result=[[WAHtmlRenderer process:page] stringValue];
	IDEXPECT( result, @"<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"></meta><title>Test Title</title></head><body></body></html>", @"html for index.html");
}

+testSelectors {
	return [NSArray arrayWithObjects:
		@"testPlainPage",
		@"testPlainPageWithTitle",
		nil];
}


@end

