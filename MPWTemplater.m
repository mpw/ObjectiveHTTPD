//
//  MPWTemplater.m
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWTemplater.h"
#import <MPWTalk/MPWScheme.h>
#import <MPWTalk/MPWBinding.h>
#import <MPWFoundation/MPWFoundation.h>
#import <MPWSideweb/WAHtmlRenderer.h>

@implementation MPWTemplater

objectAccessor( MPWScheme, sourceScheme, setSourceScheme )
idAccessor( template, setTemplate )



-valueForBinding:(MPWBinding*)aBinding
{
    id rawValue=[sourceScheme valueForBinding:aBinding];
    id page=[self template];
    [page setPath:aBinding];
    [page setContent:rawValue];
    return page;
}

-(void)dealloc
{
    [sourceScheme release];
    [template release];
    [super dealloc];
}
@end
