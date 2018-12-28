//
//  MPWSchemeHttpServer.h
//  
//
//  Created by Marcel Weiher on 10/24/11.
//  Copyright (c) 2012 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>

@class MPWHTTPServer;
@protocol Scheme;


@interface MPWSchemeHttpServer : NSObject {
    MPWHTTPServer *server;
    id  _serializer;
}

idAccessor_h( serializer, setSerializer)

@property (nonatomic, strong) id <Scheme> scheme;

// methods for instance variable 'server'
- (MPWHTTPServer*) server;

- (void) setupWebServer;

@end
