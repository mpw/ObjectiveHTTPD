//
//  microhttp.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 5/1/11.
//  Copyright 2012 Marcel Weiher. All rights reserved.
//


#import "MPWHTTPServer.h"

int main( int argc, char *argv[] ) {
	id pool=[NSAutoreleasePool new];
	
	MPWHTTPServer* server=[[[MPWHTTPServer alloc] init] autorelease];
	[server setPort:51001];
	[server startHttpd];
	fprintf(stderr, "Hello World!\n"); 
	getchar();
	exit(0);
	[pool release];
	return 0;
	
}
