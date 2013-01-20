//
//  MPWHtmlPage.h
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 7/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface MPWHtmlPage : MPWObject {
	id title;
	id content;
    id path;

}

idAccessor_h( content , setContent )
idAccessor_h( path , setPath )
@end
