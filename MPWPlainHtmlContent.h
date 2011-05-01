//
//  MPWPlainHtmlContent.h
//  WebSiteObjC
//
//  Created by Marcel Weiher on 7/8/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface MPWPlainHtmlContent : MPWObject {
	NSData* _contentData;
	NSString *resourceName;
	
}

-initWithResourceNamed:(NSString*)resourceName;

@end
