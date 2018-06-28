//
//  MPWTemplater.h
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import <MPWFoundation/MPWMappingStore.h>

@interface MPWTemplater : MPWMappingStore
{
    id  template;
}

-(void)setTemplate:newTemplate;
-(void)setSourceScheme:newSource;

@end
