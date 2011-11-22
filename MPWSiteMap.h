//
//  MPWSiteMap.h
//  MPWSideweb
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import <MPWTalk/MPWGenericScheme.h>


@interface MPWSiteMap : MPWGenericScheme {
	id root;
}

-(NSData*)htmlPageForURI:uri;

+sharedSite;
-root;

@end
