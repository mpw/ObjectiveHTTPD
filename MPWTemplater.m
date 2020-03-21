//
//  MPWTemplater.m
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 Marcel Weiher. All rights reserved.
//

#import "MPWTemplater.h"
#import <ObjectiveSmalltalk/MPWScheme.h>
#import <ObjectiveSmalltalk/MPWBinding.h>
#import <MPWFoundation/MPWFoundation.h>
#import <ObjectiveHTTPD/WAHtmlRenderer.h>
#import "MPWHtmlPage.h"

@implementation MPWTemplater

idAccessor( template, setTemplate )

-(void)setSourceScheme:(id)newSource
{
    [self setSource:newSource];
}



-(id)at:(id)aReference
{
    id rawValue=[self.source at:aReference];
    MPWHtmlPage *page = [self template];
    [page setContent:rawValue];
    [page setPath:aReference];
    return page;
    
}

-(void)dealloc
{
    [template release];
    [super dealloc];
}

+testSelectors
{
    return @[
             ];
    
}

@end

@implementation NSData(value)

-value { return [self propertyList]; }

@end


