//
//  MPWHTTPServer.h
//  microhttp
//
//  Created by Marcel Weiher on 9/6/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPWHTTPServer : NSObject {
	void *_httpd;
	int port;
	id _delegate;
	NSString *email;
	NSData *_defaultResponse;
	NSArray *types;
	NSArray *netServices;
}

-(void)setPort:(int)newVar;
-(BOOL)startHttpd;
@end
