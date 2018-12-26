//
//  MPWSchemeHttpServer.h
//  
//
//  Created by Marcel Weiher on 10/24/11.
//  Copyright (c) 2012 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>

@class MPWHTTPServer;


@interface MPWSchemeHttpServer : NSObject {
    MPWHTTPServer *server;
    id <MPWStorage> scheme;
    id  _serializer;
}

idAccessor_h( serializer, setSerializer)

// methods for instance variable 'server'
- (MPWHTTPServer*) server;

- (void) setupWebServer;

@end
