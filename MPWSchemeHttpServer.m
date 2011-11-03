//
//  MPWSchemeHttpServer.m
//  
//
//  Created by Marcel Weiher on 10/24/11.
//  Copyright (c) 2011 metaobject ltd. All rights reserved.
//

#import "MPWSchemeHttpServer.h"
#import <MPWSideWeb/MPWHTTPServer.h>
#import <MPWSideWeb/MPWPOSTProcessor.h>
#import <MPWTalk/MPWScheme.h>
#import <MPWTalk/MPWBinding.h>

@implementation MPWSchemeHttpServer

objectAccessor(MPWHTTPServer, server, setServer )
objectAccessor(MPWScheme, scheme, setScheme)
idAccessor( _serializer, setSerializer)


-serializer
{
    if ( _serializer) {
        return _serializer;
    }
    return self;
}

-(MPWBinding*)identifierForString:(NSString*)uriString
{
    return [[self scheme] bindingForName:uriString inContext:nil]; 
}

-(NSData*)serializeValue:outputValue at:(MPWBinding*)aBinding
{
    return [outputValue asData];
}

-(NSData*)get:(NSString*)uri parameters:(NSDictionary*)params
{
    MPWBinding *identifier=[self identifierForString:uri];
    id value=[identifier value];
    return [[self serializer]  serializeValue:value at:identifier];
}

-(id)deserializeData:(NSData*)inputData at:(MPWBinding*)aBinding
{
    return inputData;
}

-(NSData*)put:(NSString *)uri data:putData parameters:(NSDictionary*)params
{    id identifier=[self identifierForString:uri];

    [identifier bindValue:[self deserializeData:putData at:identifier]];
    return [uri asData];
}

-(NSData*)post:(NSString*)uri parameters:(MPWPOSTProcessor*)postData
{
    return [[[self identifierForString:uri] postWithDictionary:[postData values]] asData];
}



-(void)dealloc
{
    [scheme release];
    [server release];
    [_serializer release];
    [super dealloc];
}


-(void)setupWebServer
{
    [self setServer:[[[MPWHTTPServer alloc] init] autorelease]];
    [[self server] setDelegate:self];
    [[self server] setPort:51000];
    [[self server] setBonjourName:@"Methods"];
    [[self server] setTypes:[NSArray arrayWithObjects:@"_http._tcp.",@"_methods._tcp.",nil]];
    
}

-(void)start:(NSError**)error
{
    [[self server] start:error];
}

@end
