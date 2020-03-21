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
    // FIXME: the retain here shouldn't be necessary, but without it,
    //        this crashes under GNUstep
	return [[WAHtmlRenderer stream] retain];
}

-at:(MPWReference*)aReference
{
    @synchronized(self) {
        id result=nil;
        @autoreleasepool {
            WAHtmlRenderer* renderer = [self renderer];
            @autoreleasepool {
                [renderer writeObject:[[self source] at:aReference]];
            }
            result = [renderer result];
            [result retain];
            //            NSLog(@"will pop -[%@ objectForReference: %@",self,aReference);
        }
        //        NSLog(@"did pop -[%@ objectForReference: %@ -> %@",self,aReference,result);
        return [result autorelease];
    }
}


@end
