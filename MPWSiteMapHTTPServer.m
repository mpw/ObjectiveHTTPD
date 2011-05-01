//
//  MPWSiteMapHTTPServer.m
//  MPWSideweb
//
//  Created by Marcel Weiher on 1/22/11.
//  Copyright 2011 Marcel Weiher. All rights reserved.
//

#import "MPWSiteMapHTTPServer.h"
#import <MPWFoundation/MPWFoundation.h>

@implementation MPWSiteMapHTTPServer

idAccessor( sitemap, setSitemap )

-(NSData*)get:(NSString *)urlString parameters:(NSDictionary*)params
{
	return [sitemap binaryDataForURI:urlString];
}

-(void)dealloc
{
	[sitemap release];
	[super dealloc];
}

@end
