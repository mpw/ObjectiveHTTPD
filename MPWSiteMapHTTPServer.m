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

-(void)setSitemap:newMap
{
    [self setScheme:newMap];
    [self setSerializer:newMap];
}

@end
