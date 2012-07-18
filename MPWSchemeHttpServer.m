//
//  MPWSchemeHttpServer.m
//  
//
//  Created by Marcel Weiher on 10/24/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWSchemeHttpServer.h"
#import <MPWSideWeb/MPWHTTPServer.h>
#import <MPWSideWeb/MPWPOSTProcessor.h>
#import <MPWTalk/MPWScheme.h>
#import <MPWTalk/MPWBinding.h>

@implementation MPWSchemeHttpServer

objectAccessor(MPWHTTPServer, server, setServer )
objectAccessor(MPWScheme, scheme, _setScheme)
idAccessor( _serializer, _setSerializer)

-init {
    self=[super init];
    [self setServer:[[[MPWHTTPServer alloc] init] autorelease]];
    [[self server] setDelegate:self];
    return self;
}

-serializer
{
    if ( _serializer) {
        return _serializer;
    }
    return self;
}

-(void)setSerializer:(id)newVar
{
    [self _setSerializer:newVar];
    [newVar setSource:[self scheme]];
}


-(void)setScheme:(id)newVar
{
    [self _setScheme:newVar];
//    [[self scheme] setSource:newVar];
}


-(MPWBinding*)bindingForString:(NSString*)uriString
{
    return [[self scheme] bindingForName:uriString inContext:nil]; 
}

-(NSData*)serializeValue:outputValue at:(MPWBinding*)aBinding
{
    NSMutableData *serialized=nil;
    if ( [outputValue isKindOfClass:[NSArray class]] && [[outputValue lastObject] respondsToSelector:@selector(path)]) {
        NSMutableString *html=[NSMutableString stringWithString:@"<html><head><title>listing</title></head><body><ul>\n"];
        for ( MPWBinding *child  in outputValue) {
            NSString *dirEntry=[[child path] lastPathComponent];
            NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)dirEntry,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 );
            [html appendFormat:@"<li><a href='%@%s'>%@</a></li>\n",encodedString,[child hasChildren] ? "/" :"",dirEntry];
        }
        [html appendFormat:@"</ul></body></html>"];
        outputValue=html;
    }
    if ( !serialized) {
        serialized=[outputValue asData];
    }
    return serialized;
}


-(NSData*)get:(NSString*)uri
{
    return [uri asData];
}


-(NSData*)get:(NSString*)uri parameters:(NSDictionary*)params
{
//    NSLog(@"get: %@",uri);
    id binding=[self bindingForString:uri];
    id val1=nil;
    if ( [binding hasChildren]) {
//        NSLog(@"%@ should be a directory",binding);
        val1=[binding children];
    } else {
//        NSLog(@"%@ not a directory",binding);
        val1=[binding value];
    }
//    NSLog(@"got: %@/%@",[val1 class],val1);
    NSData* serialized=[[self serializer] serializeValue:val1 at:binding];
//    NSLog(@"serialized: %@",serialized);
    return serialized;
}

-(id)deserializeData:(NSData*)inputData at:(MPWBinding*)aBinding
{
    return inputData;
}

-(NSData*)put:(NSString *)uri data:putData parameters:(NSDictionary*)params
{    id binding=[self bindingForString:uri];

    [binding bindValue:[self deserializeData:putData at:binding]];
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
    [[self server] setPort:51000];
    [[self server] setTypes:[NSArray arrayWithObjects:@"_http._tcp.",nil]];
    
}

-(void)start:(NSError**)error
{
    [[self server] start:error];
}

-(void)stop
{
    [[self server] stop];
}

@end
