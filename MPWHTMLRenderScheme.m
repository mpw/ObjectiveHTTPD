//
//  MPWHTMLRenderScheme.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 Marcel Weiher. All rights reserved.
//

#import "MPWHTMLRenderScheme.h"
#import "WAHtmlRenderer.h"

@class MPWBinding;

@implementation MPWHTMLRenderScheme

-renderer
{
	return [WAHtmlRenderer stream];
}

-objectForReference:(MPWReference*)aReference
{
    @synchronized(self) {
        id renderer = [self renderer];
        [renderer writeObject:[[self source] objectForReference:aReference]];
        return [renderer result];
    }
}


@end
