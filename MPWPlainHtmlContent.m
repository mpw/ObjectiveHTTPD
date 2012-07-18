//
//  MPWPlainHtmlContent.m
//  WebSiteObjC
//
//  Created by Marcel Weiher on 7/8/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWPlainHtmlContent.h"
#import "MPWSiteMap.h"

@implementation MPWPlainHtmlContent

objectAccessor( NSData, _contentData, setContentData )
objectAccessor( NSString, resourceName, setResourceName )
scalarAccessor(id, source, setSource )

-contentType
{
	return @"html";
}

-loadContentData
{
	id data=nil;
	NS_DURING
	data = [source frameworkResource:resourceName category:[self contentType]];
	NS_HANDLER
	NS_ENDHANDLER
	if ( !data ) {
		NS_DURING
		[self frameworkResource:resourceName category:[self contentType]];
		NS_HANDLER
		NS_ENDHANDLER
	}
	return data;
}


-contentData
{
	if ( !_contentData ) {
        NSLog(@"%p/%@ has to reload contentData: %@",self,[self class],resourceName);
		[self setContentData:[self loadContentData]];
	}
	return _contentData;
}

-stringContent
{
	return [[self contentData] stringValue];
}

-initWithResourceNamed:(NSString*)newResourceName
{
	self = [super init];
	[self setResourceName:newResourceName];
	return self;
}

//****  FIXME:  this almost completely negates what this class is here for
//              so look at ways of removing the class instead

-initWithContentData:(NSData*)newContentData
{
    self=[super init];
    [self setContentData:newContentData];
    return self;
}

+pageWithStaticContentNamed:name source:someSource
{
    id page=[[[self alloc] initWithResourceNamed:name] autorelease];
    [page setSource:someSource];
    return page;
}

-fileSystemPathForBasePath:(NSString*)basePath
{
	return [basePath stringByAppendingPathComponent:@"index.html"];
}

-(void)renderOn:aRenderer
{
	[aRenderer writeObject:[self contentData]];
}

-(void)dealloc
{
	[_contentData release];
	[resourceName release];
	[super dealloc];
}


@end
