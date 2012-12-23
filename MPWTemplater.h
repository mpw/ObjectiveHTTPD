//
//  MPWTemplater.h
//  WebSiteObjC
//
//  Created by Marcel Weiher on 11/21/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import <ObjectiveSmalltalk/MPWFilterScheme.h>

@interface MPWTemplater : MPWFilterScheme
{
    id  template;
}

-(void)setTemplate:newTemplate;
-(void)setSourceScheme:newSource;

@end
