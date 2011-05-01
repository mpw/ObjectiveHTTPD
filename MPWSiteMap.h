//
//  MPWSiteMap.h
//  MPWSideweb
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface MPWSiteMap : MPWObject {
	id root;
}

-(NSData*)htmlPageForURI:uri;

+sharedSite;
-root;

@end
