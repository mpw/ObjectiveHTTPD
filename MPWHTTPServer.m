//
//  MPWHTTPServer.m
//  microhttp
//
//  Created by Marcel Weiher on 9/6/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import "MPWHTTPServer.h"
#import <MPWFoundation/MPWFoundation.h>
#import "MPWPOSTProcessor.h"

#include "microhttpd.h"


@implementation MPWHTTPServer


scalarAccessor(   struct MHD_Daemon *, _httpd, setHttpd )
intAccessor( port, setPort )
idAccessor( _delegate, setDelegate )
objectAccessor( NSString ,email, setEmail )
objectAccessor( NSString ,bonjourName, setBonjourName )
objectAccessor( NSArray, types, setTypes )
objectAccessor( NSArray, netServices, setNetServices )

-(void)setType:(NSString *)newType
{
	[self setTypes:[NSArray arrayWithObject:newType]];
}


- (void)netServiceDidPublish:(NSNetService *)ns
{
	// Override me to do something here...
	
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port: %d", [ns domain], [ns type], [ns name],[ns port]);
}

/**
 * Called if our bonjour service failed to publish itself.
 * This method does nothing but output a log message telling us about the published service.
 **/
- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// Override me to do something here...
	
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@)", [ns domain], [ns type], [ns name]);
	NSLog(@"Error Dict: %@", errorDict);
}



-(NSString*)bonjourDomain
{
	return @"local.";
}

-(NSString*)defaultBonjourName
{
	return @"";
}

-(void)startBonjour
{
    NSLog(@"starting bonjour");
	NSMutableArray *services=[NSMutableArray array];
	for ( NSString *type in [self types] ) {
		NSNetService *service;
		service = [[[NSNetService alloc] initWithDomain:[self bonjourDomain] type:type name:[self bonjourName] port:[self port]] autorelease];
		[services addObject:service];           
	}
	[self setNetServices:services];
	
	[[[self netServices] do] setDelegate:self];
	[[[self netServices] do] publish];
    NSLog(@"did start bonjour:  %@",[self netServices]);
	
}

-(void)stopBonjour
{
    NSLog(@"stopping net services");
	[[[self netServices] do] stop];
	[self setNetServices:nil];
	
}


-(BOOL)start:(NSError**)error
{
	[self startHttpd];
	[self startBonjour];
	return YES;
}



-(int)defaultPort
{
	return 51001;
}

-init
{
	self=[super init];
	[self setPort:[self defaultPort]];
    [self setBonjourName:[self defaultBonjourName]];
	return self;
}

-delegate
{
	if ( [self _delegate] ) {
		return [self _delegate];
	}
	return self;
}

-(struct MHD_Daemon*)httpd { return (struct MHD_Daemon*)[self _httpd]; }

-(int)acceptConnectionOnSoccaddr:(const struct sockaddr *)addr length:(int)addrlen
{
	return MHD_YES;
}

int  AcceptPolicyCallback(void *cls,
							const struct sockaddr * addr,
							socklen_t addrlen)
{
	return [(id)cls acceptConnectionOnSoccaddr:addr length:addrlen];
}


-(NSData*)get:(NSString*)urlString
{
	return [self get:urlString parameters:nil];
}

objectAccessor( NSData,_defaultResponse, setDefaultResponse )

-(NSData*)defaultResponse
{
	if ( !_defaultResponse ) {
		[self setDefaultResponse:[NSData dataWithContentsOfMappedFile:@"default.txt"]];
	}
	return _defaultResponse;
}

-(NSData*)get:(NSString *)urlString parameters:(NSDictionary*)params
{
    return [[NSString stringWithFormat:@"<html><head></head><body>%@ serving: %@</body></html>\n",
             [self className],urlString]  dataUsingEncoding:NSISOLatin1StringEncoding];
}

-(NSData*)options:(NSString *)urlString parameters:(NSDictionary*)params
{
    return [NSData data];
}


-(NSData*)propfind:(NSString *)urlString data:(NSData*)propFindData parameters:(NSDictionary*)params
{
    return [NSData data];
}

-(NSData*)post:(NSString *)urlString parameters:(MPWPOSTProcessor*)params
{
	NSLog(@	"POSTed some data to: %@",urlString);
	return [NSData data];
}

-(NSData*)put:(NSString *)urlString data:putData parameters:(NSDictionary*)params
{
 	NSLog(@	"PUT some data to: %@",urlString);
	return [NSData data];
}


 void RequestCompletedCallback(void *cls,
								 struct MHD_Connection * connection,
								 void **con_cls,
								 enum MHD_RequestTerminationCode toe)
{
//	[(id)cls requestCompletedForReason:toe  withObject:(id)*con_cls];
	[(id)*con_cls release];
}

static int  addKeyValuesToDictionary(void *cls,
						 enum MHD_ValueKind kind,
						 const char *key, const char *value)
{
	[(NSMutableDictionary*)cls setObject:[NSString stringWithCString:value encoding:NSISOLatin1StringEncoding]
								  forKey:[NSString stringWithCString:key encoding:NSISOLatin1StringEncoding]];
	return MHD_YES;
}

static int iterate_post (void *cls,
						 enum MHD_ValueKind kind,
						 const char *key,
						 const char *filename,
						 const char *content_type,
						 const char *transfer_encoding,
						 const char *bytes, uint64_t off, size_t size) {

	MPWPOSTProcessor *processor=(MPWPOSTProcessor*)cls ;
	NSString *fileNameString = filename ? [NSString stringWithCString:filename encoding:NSISOLatin1StringEncoding] : nil;
	NSString *keyString = key ? [NSString stringWithCString:key encoding:NSISOLatin1StringEncoding] : nil;
	if ( keyString ) {
		[processor appendBytes:bytes length:size 
						 toKey:keyString
					  filename:fileNameString
				   contentType:nil];
	} else {
		NSLog(@"no key for POST data");
	}
	return MHD_YES;
}

-(NSData*)errorPage:exception
{
    return [@"Not Found 404\n" asData]; 
}

-(int)handleGetLikeSelector:(SEL)httpVerbSelector withURL:(const char*)url onConnection:(struct MHD_Connection*)connection context:(void**)con_cls
{
    //			fprintf(stderr, "in GET\n");
    //			fprintf(stderr, "will get NSPlatformCurrentThread\n");
    //			NSPlatformSetCurrentThread([[NSThread alloc] init]);
    //			NSPlatformCurrentThread();
    //			[NSObject new];
    //			fprintf(stderr, "will create pool\n");
    id pool=[NSAutoreleasePool new];
    //			fprintf(stderr, "GET url: '%s'\n",url);
    NSString *urlstring=[NSString stringWithCString:url encoding:NSISOLatin1StringEncoding];
    //			fprintf(stderr, "did create urlstring\n");
    NSMutableDictionary *parameterDict=[NSMutableDictionary dictionary];
    NSMutableDictionary *headerDict=[NSMutableDictionary dictionary];
    MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);
    MHD_get_connection_values (connection, MHD_HEADER_KIND,  addKeyValuesToDictionary,( void *)headerDict);
    NSLog(@"parameter dict: %@",parameterDict);
    NSLog(@"header dict: %@",headerDict);
    NSData *responseData = nil;
    int responseCode=0;
    @try {
        responseData=[[self delegate]  performSelector:httpVerbSelector withObject:urlstring withObject:parameterDict];
 //       responseData=[[self delegate] get:urlstring parameters:parameterDict];
        responseCode=MHD_HTTP_OK;
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@",exception);
        responseData=[self errorPage:exception];
        responseCode=404;
    }
    responseData=[responseData asData];
    
    struct MHD_Response* response= MHD_create_response_from_data([responseData length], ( void*)[responseData bytes], NO, NO);

    MHD_add_response_header (response, "Connection", "Keep-Alive");
    MHD_add_response_header (response, "Keep-Alive", "timeout=3, max=100");
//    MHD_add_response_header (response, "Expires", "Tue, 1 Jan 2013 08:12:31 GMT");
//    MHD_add_response_header (response, "Content-Type", "text/xml");
    MHD_add_response_header (response, "DAV", "1,2");
    MHD_add_response_header (response, "Allow", "OPTIONS,GET,HEAD,POST,DELETE,TRACE,PROPFIND,PROPPATCH,COPY,MOVE,LOCK,UNLOCK");

    int ret = MHD_queue_response(connection,
                                 responseCode,
                                 response);
    MHD_destroy_response(response);
    *con_cls = [responseData retain];
    [pool drain];
    return ret;
}

-(int)handleGet:(const char*)url onConnection:(struct MHD_Connection*)connection context:(void**)con_cls
{
    return [self handleGetLikeSelector:@selector(get:parameters:) withURL:url onConnection:connection context:con_cls];
}

-(int)handleOptions:(const char*)url onConnection:(struct MHD_Connection*)connection context:(void**)con_cls
{
    int retval= [self handleGetLikeSelector:@selector(options:parameters:) withURL:url onConnection:connection context:con_cls];
    
    
    return retval;
}

-(int)handlePropfind:(const char*)url onConnection:(struct MHD_Connection*)connection context:(void**)con_cls
{
    //			fprintf(stderr, "in GET\n");
    //			fprintf(stderr, "will get NSPlatformCurrentThread\n");
    //			NSPlatformSetCurrentThread([[NSThread alloc] init]);
    //			NSPlatformCurrentThread();
    //			[NSObject new];
    //			fprintf(stderr, "will create pool\n");
    id pool=[NSAutoreleasePool new];
    //			fprintf(stderr, "GET url: '%s'\n",url);
    NSString *urlstring=[NSString stringWithCString:url encoding:NSISOLatin1StringEncoding];
    //			fprintf(stderr, "did create urlstring\n");
    NSMutableDictionary *parameterDict=[NSMutableDictionary dictionary];
    NSMutableDictionary *headerDict=[NSMutableDictionary dictionary];
    MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);
    MHD_get_connection_values (connection, MHD_HEADER_KIND,  addKeyValuesToDictionary,( void *)headerDict);
    NSLog(@"parameter dict: %@",parameterDict);
    NSLog(@"header dict: %@",headerDict);
    NSData *responseData = nil;
    int responseCode=0;
    @try {
        responseData=[[self delegate]  propfind:urlstring parameters:headerDict ];
        //       responseData=[[self delegate] get:urlstring parameters:parameterDict];
        responseCode=MHD_HTTP_OK;
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@",exception);
        responseData=[self errorPage:exception];
        responseCode=404;
    }
    responseData=[responseData asData];
    
    struct MHD_Response* response= MHD_create_response_from_data([responseData length], ( void*)[responseData bytes], NO, NO);
    
    MHD_add_response_header (response, "Connection", "Keep-Alive");
    MHD_add_response_header (response, "Keep-Alive", "timeout=3, max=100");
    //    MHD_add_response_header (response, "Expires", "Tue, 1 Jan 2013 08:12:31 GMT");
    MHD_add_response_header (response, "Content-Type", "text/xml");
    MHD_add_response_header (response, "DAV", "1,2");
    MHD_add_response_header (response, "Allow", "OPTIONS,GET,HEAD,POST,DELETE,TRACE,PROPFIND,PROPPATCH,COPY,MOVE,LOCK,UNLOCK");
    
    int ret = MHD_queue_response(connection,
                                 responseCode,
                                 response);
    MHD_destroy_response(response);
    *con_cls = [responseData retain];
    [pool drain];
    return ret;
}


int AccessHandlerCallback(void *cls,
							  struct MHD_Connection * connection,
							  const char *url,
							  const char *method,
							  const char *version,
							  const char *upload_data,
							  size_t *upload_data_size,
							  void **con_cls)
{
	id self=(id)cls;
	if ( *con_cls == NULL ) {
        fprintf(stderr, "initial access handler callback: %s: url: '%s'\n",method,url);
		// first time
		static int requests=0;
		if ( ++requests % 100 ==0 ) {
			NSLog(@"request: %d",requests);
		}
		if ( !strcmp("GET", method) ||  !strcmp("OPTIONS", method)  ) {
            //			fprintf(stderr, "GET url: '%s'\n",url);
			*con_cls = self;
		} else 	if ( !strcmp("PUT", method)  ||  !strcmp("PROPFIND", method) ) {
            NSMutableData* putData=[[NSMutableData alloc] init];
			*con_cls = putData;
		} else 	if ( !strcmp("POST", method) ) {
			id pool=[NSAutoreleasePool new];
			fprintf(stderr, "POST url: '%s'\n",url);
			MPWPOSTProcessor* processor=[MPWPOSTProcessor processor];
			*con_cls = processor;
			[processor setProcessor:(void*) MHD_create_post_processor (connection, 8192 , 
                                         iterate_post, (void*) processor)];   
			[processor retain];
			[pool release];
            
		}
		return MHD_YES;
	} else {
        fprintf(stderr, "continuing access handler callback: %s: url: '%s'\n",method,url);
		if ( !strcmp("GET", method) ) {
            return [self handleGet:url onConnection:connection context:con_cls];
        }else 	if ( !strcmp("OPTIONS", method) ) {
            return [self handleOptions:url onConnection:connection context:con_cls];
        }else 	if ( !strcmp("PUT", method) || !strcmp("PROPFIND", method)) {
			id pool=[NSAutoreleasePool new];
			NSMutableData *putData=(NSMutableData*)*con_cls;
			if ( *upload_data_size != 0 ) {
                [putData appendBytes:upload_data length:*upload_data_size];
				*upload_data_size = 0;
				
				return MHD_YES;
			} else {	
				NSString *urlstring=[NSString stringWithCString:url encoding:NSISOLatin1StringEncoding];
				//			fprintf(stderr, "did create urlstring\n");
                //				MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);
                
				NSMutableDictionary *parameterDict=[NSMutableDictionary dictionary];
				MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);
                NSMutableDictionary *headerDict=[NSMutableDictionary dictionary];
				MHD_get_connection_values (connection, MHD_HEADER_KIND,  addKeyValuesToDictionary,( void *)headerDict);
                NSData *responseData=nil;
                if  (! strcmp("PUT", method)) {
                    responseData = [[self delegate] put:urlstring data:putData parameters:parameterDict];
                } else {
                    
                    responseData = [[self delegate] propfind:urlstring data:putData parameters:headerDict];
                }
                
				//			fprintf(stderr, "did get responesData\n");
                [putData release];
				struct MHD_Response* response= MHD_create_response_from_data([responseData length], ( void*)[responseData bytes], NO, NO);
				
				int ret = MHD_queue_response(connection,
											 MHD_HTTP_OK,
											 response);
				MHD_destroy_response(response);
				*con_cls = [responseData retain];
				
				[pool drain];
				return ret;            
			}	//			fprintf(stderr, "did get responesData\n");
		} else 	if ( !strcmp("POST", method) ) {
//			NSLog(@"POST continuation upload size: %d",*upload_data_size);
			id pool=[NSAutoreleasePool new];
			MPWPOSTProcessor *processor=(MPWPOSTProcessor*)*con_cls;
			if ( *upload_data_size != 0 ) {
				MHD_post_process ([processor processor], upload_data,	
								  *upload_data_size);
				*upload_data_size = 0;
				
				return MHD_YES;
			} else {	
				NSString *urlstring=[NSString stringWithCString:url encoding:NSISOLatin1StringEncoding];
				//			fprintf(stderr, "did create urlstring\n");
//				MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);

				NSMutableDictionary *parameterDict=[NSMutableDictionary dictionary];
				MHD_get_connection_values (connection, MHD_GET_ARGUMENT_KIND,  addKeyValuesToDictionary,( void *)parameterDict);
				[processor addParameters:parameterDict];
				NSData *responseData = [[self delegate] post:urlstring parameters:processor];
				//			fprintf(stderr, "did get responesData\n");
				struct MHD_Response* response= MHD_create_response_from_data([responseData length], ( void*)[responseData bytes], NO, NO);
				
				int ret = MHD_queue_response(connection,
											 MHD_HTTP_OK,
											 response);
				MHD_destroy_response(response);
				*con_cls = [responseData retain];
				
				[pool drain];
				return ret;
			
			}
			return NO;
		}
	}

	return NO;
}


-(BOOL)startHttpd
{
	int attempts=0;
    int initialPort=[self port];
    while ( ![self httpd] && attempts < 50 ) {
        [self setHttpd:MHD_start_daemon ( MHD_USE_SELECT_INTERNALLY ,
                                     [self port],
                                     AcceptPolicyCallback ,
                                     self,
                                     AccessHandlerCallback ,
									 self,
									 MHD_OPTION_NOTIFY_COMPLETED,
									 RequestCompletedCallback,
									 self,
									 MHD_OPTION_THREAD_POOL_SIZE,
									 20,
									 MHD_OPTION_END
									 )];
        if (![self httpd]) {
            [self setPort:[self port]+1];
            attempts++;
        }
    }
    NSLog(@"=== did start %p on port %d",[self httpd],[self port]);
	return [self httpd] != NULL;
}


-(void)stopHttpd
{
	if ( [self httpd] )  {
        NSLog(@"stopping httpd: %p",[self httpd]);
		MHD_stop_daemon ([self httpd]);
        NSLog(@"=== did stop %p",[self httpd]);
		[self setHttpd:NULL];
	}
}

-(void)stop
{
    [self stopBonjour];
    [self stopHttpd];
}

-(void)dealloc
{
	[self stop];
	[super dealloc];
}


@end
