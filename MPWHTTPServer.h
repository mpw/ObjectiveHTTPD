//
//  MPWHTTPServer.h
//  microhttp
//
//  Created by Marcel Weiher on 9/6/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface MPWHTTPServer : NSObject {
	void *_httpd;
	int port;
	id _delegate;
	NSString *email;
	NSString *bonjourName;
	NSData *_defaultResponse;
	NSArray *types;
	NSArray *netServices;
    NSString *_defaultMimeType;
    int threadPoolSize;

}

-(int)port;
-(void)setPort:(int)newVar;
-(BOOL)startHttpd;
-(BOOL)start:(NSError**)errorP;
-(void)stop;


idAccessor_h( delegate, setDelegate )
intAccessor_h( threadPoolSize, setThreadPoolSize )


@end
