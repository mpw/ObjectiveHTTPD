//
//  MPWHTMLRenderScheme.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWHTMLRenderScheme.h"
#import "WAHtmlRenderer.h"

@class MPWBinding;

@implementation MPWHTMLRenderScheme

-renderer
{
	return [WAHtmlRenderer stream];
}

-valueForBinding:(MPWBinding*)aBinding
{
    @synchronized(self) {
        id renderer = [self renderer];
        [renderer writeObject:[[self source] valueForBinding:aBinding]];
        return [renderer result];
    }
}


@end
