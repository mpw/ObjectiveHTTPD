//
//  MPWHTMLRenderScheme.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 Marcel Weiher. All rights reserved.
//

#import "MPWHTMLRenderScheme.h"
#import "WAHtmlRenderer.h"
#import "MPWHtmlPage.h"

@class MPWBinding;

@implementation MPWHTMLRenderScheme

-renderer
{
    // FIXME: the retain here shouldn't be necessary, but without it,
    //        this crashes under GNUstep
	return [[WAHtmlRenderer stream] retain];
}

-at:(MPWReference*)aReference
{
    @synchronized(self) {
        id result=[[self source] at:aReference];
        if ( [result isKindOfClass:[MPWHtmlPage class]] ) {
            @autoreleasepool {
                WAHtmlRenderer* renderer = [self renderer];
                @autoreleasepool {
                    [renderer writeObject:result];
                }
                result = [renderer result];
                [result retain];
                //            NSLog(@"will pop -[%@ objectForReference: %@",self,aReference);
            }
            [result autorelease];
        }
        //        NSLog(@"did pop -[%@ objectForReference: %@ -> %@",self,aReference,result);
        return result;
    }
}


@end
