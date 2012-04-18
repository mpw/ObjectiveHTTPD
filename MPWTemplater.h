//
//  MPWTemplater.h
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import <MPWTalk/MPWGenericScheme.h>

@interface MPWTemplater : MPWGenericScheme
{
    MPWScheme *sourceScheme;
    id  template;
}

-(void)setTemplate:newTemplate;
-(void)setSourceScheme:newSource;

@end
