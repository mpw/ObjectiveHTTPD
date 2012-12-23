//
//  MPWTemplater.m
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWTemplater.h"
#import <ObjectiveSmalltalk/MPWScheme.h>
#import <ObjectiveSmalltalk/MPWBinding.h>
#import <MPWFoundation/MPWFoundation.h>
#import <MPWSideweb/WAHtmlRenderer.h>

@implementation MPWTemplater

idAccessor( template, setTemplate )

-(void)setSourceScheme:(id)newSource
{
    [self setSource:newSource];
}


-valueForBinding:(MPWBinding*)aBinding
{
    id rawValue=[[self source] valueForBinding:aBinding];
    id page=[self template];
    [page setPath:aBinding];
    [page setContent:rawValue];
    return page;
}

-(void)dealloc
{
    [template release];
    [super dealloc];
}
@end
