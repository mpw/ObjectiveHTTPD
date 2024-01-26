//
//  MPWSchemeHttpServer.m
//  
//
//  Created by Marcel Weiher on 10/24/11.
//  Copyright (c) 2012 metaobject ltd. All rights reserved.
//

#import "MPWSchemeHttpServer.h"
#import <ObjectiveHTTPD/MPWHTTPServer.h>
#import <ObjectiveHTTPD/MPWPOSTProcessor.h>
#import <ObjectiveSmalltalk/STMessagePortDescriptor.h>
#import <MPWFoundation/MPWResource.h>
#import <ObjectiveSmalltalk/MPWScheme.h>

@implementation MPWSchemeHttpServer

objectAccessor(MPWHTTPServer*, server, setServer )
idAccessor( _serializer, _setSerializer)

-(instancetype)init {
    self=[super init];
    [self setServer:[[[MPWHTTPServer alloc] init] autorelease]];
    [[self server] setDelegate:self];
    return self;
}

+(instancetype)server
{
    return [[[self alloc] init] autorelease];
}


+(instancetype)serverOnPort:(int)aPort
{
    MPWSchemeHttpServer *server=[self server];
    [[server server] setPort:aPort];
    return server;
}

+(instancetype)serveOnPort:(int)aPort
{
    MPWSchemeHttpServer *server=[self serverOnPort:aPort];
    [server start:nil];
    return server;
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



-(MPWBinding*)bindingForString:(NSString*)uriString
{
    return [[self scheme] bindingForName:uriString inContext:nil]; 
}

-(MPWResource*)serializeValue:outputValue at:(MPWBinding*)aBinding
{
//    NSLog(@"serializeValue: %@ at:%@",[outputValue class],[aBinding path]);
    MPWResource *serialized=nil;
//    NSLog(@"web-serialize a %@ for %@: %@",[outputValue class],[aBinding path],outputValue);
    if ( [outputValue isKindOfClass:[NSArray class]] && [[outputValue lastObject] respondsToSelector:@selector(path)]) {
//        NSLog(@"directory listing");
        NSMutableString *html=[NSMutableString stringWithString:@"<html><head><title>listing</title></head><body><ul>\n"];
        for ( MPWBinding *child  in outputValue) {
            NSString *dirEntry=[[child path] lastPathComponent];
            NSString *encodedString = [dirEntry stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@" !*'();:@&=+$,/?%#[]"] invertedSet]];

            [html appendFormat:@"<li><a href='%@%s'>%@</a></li>\n",encodedString,[child hasChildren] ? "/" :"",dirEntry];
        }
        [html appendFormat:@"</ul></body></html>"];
        outputValue=html;
        serialized=[[MPWResource new] autorelease];
        [serialized setRawData:[outputValue asData]];
        [serialized setMIMEType:@"text/html"];
//        NSLog(@"serialized: %@",[serialized class]);
    } else if ( [outputValue isKindOfClass:[MPWResource class]]) {
        serialized=outputValue;
    } else if ( outputValue == nil) {
        serialized = nil;
    } else {
        outputValue=[outputValue asData];
        serialized=[[[MPWResource alloc] init] autorelease];
        serialized.rawData=outputValue;
        NSString *path=[aBinding path];
        NSString *extension = [path pathExtension];
        if ( [extension isEqual:@"png"]) {
            serialized.MIMEType=@"image/png";
        } else if ( [extension isEqual:@"css"]) {
            serialized.MIMEType=@"text/css";
        } else {
            serialized.MIMEType=@"text/html";
        }
    }
    return serialized;
}


-(NSData*)get:(NSString*)uri
{
    return [self get:uri parameters:nil];
}

-(void)graphViz:(MPWByteStream *)aStream
{
    [aStream printFormat:@"\"HTTP-Server\\nPort: %d\" -> %@ [label=store]\n",[[self server] port],[self.scheme graphVizName]];
    [self.scheme graphViz:aStream];
}

-(MPWResource*)get:(NSString*)uri parameters:(NSDictionary*)params
{
//    NSLog(@"get: %@ parameters: %@",uri,params);
    MPWBinding* binding=[self bindingForString:uri];
//    NSLog(@"binding: %@",binding);
    id val1=nil;
    if ( [binding hasChildren]) {      // FIXME
        val1=[binding children];
//        NSLog(@"%@ had children: %@",binding,val1);
    } else {
        val1=[binding value];
//        NSLog(@"%@ did not have children: %@ %p %@",binding,val1,val1,[val1 class]);
    }
    MPWResource* serialized=[[self serializer] serializeValue:val1 at:binding];
//    NSLog(@"value: %@ serialized: %@",val1,serialized);
    return serialized;
}

-(NSData*)options:(NSString *)urlString parameters:(NSDictionary*)params
{
    return [NSData data];
}


-(NSData*)propfind:(NSString *)urlString data:(NSData*)propFindData parameters:(NSDictionary*)params
{
    NSString *responseDepth0=@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
    <D:multistatus xmlns:D=\"DAV:\">\n\
    <D:response xmlns:lp1=\"DAV:\" xmlns:lp2=\"http://apache.org/dav/props/\">\n\
    <D:href>/webdav/</D:href>\n\
    <D:propstat>\n\
    <D:prop>\n\
    <lp1:resourcetype><D:collection/></lp1:resourcetype>\n\
    <lp1:creationdate>2013-02-15T13:28:33Z</lp1:creationdate>\n\
    <lp1:getlastmodified>Fri, 15 Feb 2013 13:28:33 GMT</lp1:getlastmodified>\n\
    <lp1:getetag>\"ccfbc3-aa-4d5c35a0d4240\"</lp1:getetag>\n\
    <D:supportedlock>\n\
    <D:lockentry>\n\
    <D:lockscope><D:exclusive/></D:lockscope>\n\
    <D:locktype><D:write/></D:locktype>\n\
    </D:lockentry>\n\
    <D:lockentry>\n\
    <D:lockscope><D:shared/></D:lockscope>\n\
    <D:locktype><D:write/></D:locktype>\n\
    </D:lockentry>\n\
    </D:supportedlock>\n\
    <D:lockdiscovery/>\n\
    <D:getcontenttype>httpd/unix-directory</D:getcontenttype>\n\
    </D:prop>\n\
    <D:status>HTTP/1.1 200 OK</D:status>\n\
    </D:propstat>\n\
    </D:response>\n\
    </D:multistatus>\n";

#if 0
    NSString *responseDepth1=@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
    <D:multistatus xmlns:D=\"DAV:\">\
    <D:response xmlns:lp1=\"DAV:\" xmlns:lp2=\"http://apache.org/dav/props/\">\
    <D:href>/webdav/</D:href>\
    <D:propstat>\
    <D:prop>\
    <lp1:resourcetype><D:collection/></lp1:resourcetype>\
    <lp1:creationdate>2013-02-15T13:28:33Z</lp1:creationdate>\
    <lp1:getlastmodified>Fri, 15 Feb 2013 13:28:33 GMT</lp1:getlastmodified>\
    <lp1:getetag>\"ccfbc3-aa-4d5c35a0d4240\"</lp1:getetag>\
    <D:supportedlock>\
    <D:lockentry>\
    <D:lockscope><D:exclusive/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    <D:lockentry>\
    <D:lockscope><D:shared/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    </D:supportedlock>\
    <D:lockdiscovery/>\
    <D:getcontenttype>httpd/unix-directory</D:getcontenttype>\
    </D:prop>\
    <D:status>HTTP/1.1 200 OK</D:status>\
    </D:propstat>\
    </D:response>\
    <D:response xmlns:lp1=\"DAV:\" xmlns:lp2=\"http://apache.org/dav/props/\">\
    <D:href>/webdav/hi.txt</D:href>\
    <D:propstat>\
    <D:prop>\
    <lp1:resourcetype/>\
    <lp1:creationdate>2013-02-15T13:28:33Z</lp1:creationdate>\
    <lp1:getcontentlength>3</lp1:getcontentlength>\
    <lp1:getlastmodified>Fri, 15 Feb 2013 13:28:33 GMT</lp1:getlastmodified>\
    <lp1:getetag>\"cd2931-3-4d5c35a0d4240\"</lp1:getetag>\
    <lp2:executable>F</lp2:executable>\
    <D:supportedlock>\
    <D:lockentry>\
    <D:lockscope><D:exclusive/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    <D:lockentry>\
    <D:lockscope><D:shared/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    </D:supportedlock>\
    <D:lockdiscovery/>\
    <D:getcontenttype>text/plain</D:getcontenttype>\
    </D:prop>\
    <D:status>HTTP/1.1 200 OK</D:status>\
    </D:propstat>\
    </D:response>\
    <D:response xmlns:lp1=\"DAV:\" xmlns:lp2=\"http://apache.org/dav/props/\">\
    <D:href>/webdav/letter.pages</D:href>\
    <D:propstat>\
    <D:prop>\
    <lp1:resourcetype/>\
    <lp1:creationdate>2013-02-15T12:40:36Z</lp1:creationdate>\
    <lp1:getcontentlength>700140</lp1:getcontentlength>\
    <lp1:getlastmodified>Fri, 15 Feb 2013 12:40:36 GMT</lp1:getlastmodified>\
    <lp1:getetag>\"cd1fb8-aaeec-4d5c2ae91b900\"</lp1:getetag>\
    <lp2:executable>F</lp2:executable>\
    <D:supportedlock>\
    <D:lockentry>\
    <D:lockscope><D:exclusive/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    <D:lockentry>\
    <D:lockscope><D:shared/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    </D:supportedlock>\
    <D:lockdiscovery/>\
    </D:prop>\
    <D:status>HTTP/1.1 200 OK</D:status>\
    </D:propstat>\
    </D:response>\
    <D:response xmlns:lp1=\"DAV:\" xmlns:lp2=\"http://apache.org/dav/props/\">\
    <D:href>/webdav/uploads/</D:href>\
    <D:propstat>\
    <D:prop>\
    <lp1:resourcetype><D:collection/></lp1:resourcetype>\
    <lp1:creationdate>2013-02-15T09:56:08Z</lp1:creationdate>\
    <lp1:getlastmodified>Fri, 15 Feb 2013 09:52:46 GMT</lp1:getlastmodified>\
    <lp1:getetag>\"ccfbca-44-4d5c05659b780\"</lp1:getetag>\
    <D:supportedlock>\
    <D:lockentry>\
    <D:lockscope><D:exclusive/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    <D:lockentry>\
    <D:lockscope><D:shared/></D:lockscope>\
    <D:locktype><D:write/></D:locktype>\
    </D:lockentry>\
    </D:supportedlock>\
    <D:lockdiscovery/>\
    <D:getcontenttype>httpd/unix-directory</D:getcontenttype>\
    </D:prop>\
    <D:status>HTTP/1.1 200 OK</D:status>\
    </D:propstat>\
    </D:response>\
    </D:multistatus>\n";
#endif
    NSLog(@"propfind data: '%@'",[propFindData stringValue]);
    
    return [responseDepth0 asData];
}


-(id)deserializeData:(NSData*)inputData at:(MPWBinding*)aBinding
{
    return inputData;
}

-(NSData*)put:(NSString *)uri data:putData parameters:(NSDictionary*)params
{
//    NSLog(@"put: %@ parameter: %@",uri,[putData stringValue]);
    MPWBinding* binding=[self bindingForString:uri];
    
    [binding setValue:[self deserializeData:putData at:binding]];
    return [uri asData];
}

-(NSData*)patch:(NSString *)uri data:putData parameters:(NSDictionary*)params
{
    NSLog(@"patch: %@ parameter: %@",uri,[putData stringValue]);
//    id binding=[self bindingForString:uri];
    
    return [uri asData];
}

-(NSData*)post:(NSString*)uri parameters:(MPWPOSTProcessor*)postData
{
    NSLog(@"post: %@ parameter: %@",uri,[[[postData values] objectForKey:@"data"] stringValue]);
//    id binding=[self bindingForString:uri];

    
//    return [[binding postWithDictionary:[postData values]] asData];
    NSString *responseString = @"{\"email\":\"kristijan+555@6wunderkinder.com\",\"id\":7422014,\"access_token\":\"167d01a29415271c974e3beeea7037db700590431cd862386495addcc4cb\",\"name\":\"Krisso\",\"pro\":true,\"created_at\":\"2014-01-06T10:41:47Z\"}";
    return [responseString asData];
}



-(void)dealloc
{
    [_scheme release];
    [server release];
    [_serializer release];
    [super dealloc];
}


-(void)setPort:(int)newPort
{
    [[self server] setPort:newPort];
}

-(int)port
{
    return [[self server] port];
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

-(void)start
{
    [self start:nil];
}

-(void)stop
{
    [[self server] stop];
}

-defaultOutputPort
{
    return [[[STMessagePortDescriptor alloc] initWithTarget:self key:@"scheme" protocol:@protocol(MPWStorage) sends:YES] autorelease];
}


-(int)runWithStdin:(id <StreamSource>)source Stdout:(MPWByteStream*)target
{
    return [(id)[self server] runWithStdin:source Stdout:target];
}


@end

#import "MPWSiteMap.h"


@implementation MPWSchemeHttpServer(testing)

+(void)testBasicGETAccessOfValues
{
    MPWSiteMap *site=[MPWSiteMap store];
    MPWSchemeHttpServer *server=[[MPWSchemeHttpServer new] autorelease];
    server.scheme=site;
    site[[site referenceForPath:@"hello"]]=@"world";
    IDEXPECT( [[server get:@"hello"] stringValue], @"world", @"server get");
}

+(void)testBasicGETAccessOfDirectories
{
    MPWSiteMap *site=[MPWSiteMap store];
    MPWSchemeHttpServer *server=[[MPWSchemeHttpServer new] autorelease];
    server.scheme=site;
    site[[site referenceForPath:@"hello"]]=@"world";
    IDEXPECT( [[server get:@"hello"] stringValue], @"world", @"server get");
}


+testSelectors
{
    return @[
             @"testBasicGETAccessOfValues",
             @"testBasicGETAccessOfDirectories",
             ];
}

@end

@implementation MPWAbstractStore(httpServing)

-(MPWSchemeHttpServer*)serveOnPort:(int)aPort
{
    MPWSchemeHttpServer *server=[MPWSchemeHttpServer serverOnPort:aPort];
    [server setScheme:self];
    [server start:nil];
    return server;
}

-(void)waitOnPort:(int)aPort
{
    [self serveOnPort:aPort];
    [[NSRunLoop currentRunLoop] run];
}


+(MPWSchemeHttpServer*)serveOnPort:(int)aPort
{
    return [[self store] serveOnPort:aPort];
}

-(MPWSchemeHttpServer*)serveOn:(NSNumber*)aPort
{
    return [self serveOnPort:aPort.intValue];
}

-(int)runWithStdin:(id <StreamSource>)source Stdout:(MPWByteStream*)target
{
    NSLog(@"%@ runWithStdin..",[self class]);
    MPWSchemeHttpServer *server=[MPWSchemeHttpServer server];
    [server setScheme:self];
    return [server runWithStdin:source Stdout:target];
}



@end

@interface MPWStripLeadingSlashStore : MPWMappingStore{ } @end
@implementation MPWStripLeadingSlashStore

-(id<MPWReferencing>)mapReference:(id<MPWReferencing>)aReference
{
    NSString *path=[aReference path];
    if ( [path hasPrefix:@"/"]) {
        path=[path substringFromIndex:1];
    }
    return path;
}



@end

@implementation MPWDictStore(httpServing)

-(MPWSchemeHttpServer*)serveOnPort:(int)aPort
{
    MPWStripLeadingSlashStore *s=[MPWStripLeadingSlashStore storeWithSource:self];
    return [s serveOnPort:aPort];
}

@end
