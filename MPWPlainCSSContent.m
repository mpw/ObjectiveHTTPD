//
//  MPWPlainCSSContent.m
//  WebSiteObjC
//
//  Created by Marcel Weiher on 7/8/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWPlainCSSContent.h"


@implementation MPWPlainCSSContent

-contentType
{
	return @"css";
}


-(void)renderOn:aRenderer
{
	[aRenderer element:"style" attributes:@" type='text/css'" content:[self contentData]];
}

@end
