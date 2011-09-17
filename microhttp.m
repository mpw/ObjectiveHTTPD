//
//  microhttp.m
//  MPWSideweb
//
//  Created by Marcel Weiher on 5/1/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//


#import "MPWHTTPServer.h"

int main( int argc, char *argv[] ) {
	id pool=[NSAutoreleasePool new];
	
	id server=[[[MPWHTTPServer alloc] init] autorelease];
	[server setPort:51001];
	[server startHttpd];
	fprintf(stderr, "Hello World!\n"); 
	getchar();
	exit(0);
	[pool release];
	return 0;
	
}