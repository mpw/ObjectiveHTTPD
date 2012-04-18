//
//  MPWSiteMapHTTPServer.m
//  MPWSideweb
//
//  Created by Marcel Weiher on 1/22/11.
//  Copyright 2012 Marcel Weiher. All rights reserved.
//

#import "MPWSiteMapHTTPServer.h"
#import <MPWFoundation/MPWFoundation.h>
#import "MPWTemplater.h"

@implementation MPWSiteMapHTTPServer

-(void)setSitemap:newMap
{
    id templater=[[[MPWTemplater alloc] init] autorelease];
//    [templater setTemplate:[[[MPWHtmlPage alloc] init] autorelease]];
    [self setScheme:newMap];
}

                          
@end
