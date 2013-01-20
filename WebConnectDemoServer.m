//
//  WebConnectDemoServer.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 1/22/11.
//  Copyright 2012 Marcel Weiher. All rights reserved.
//

#import "WebConnectDemoServer.h"
#import "MPWPOSTProcessor.h"

@implementation WebConnectDemoServer

static int k=0;
static int seed=2020;
-(void)increase
{
	k++;
}

-(NSData*)get:(NSString *)urlString parameters:(NSDictionary*)params
{
	
#if 0
	seed=rand();
	for (int i=0;i<10000000;i++) {
		k++;
		k=k^seed;
	}
#endif
	if ( [urlString length] < 2 ) {
		return [self defaultResponse];
	} else {
		NSMutableString *string=[NSMutableString string];
		
		
		
		[string appendFormat:@"<html>\n"];
		[string appendFormat:@"<html><head><title>libmicrohttpd test</title></head>\n"];
		[string appendFormat:@"<body>\n"];
		if ( [urlString hasPrefix:@"/image"] ) {
			return [NSData dataWithContentsOfMappedFile:[NSString stringWithFormat:@"/tmp/fileUploads/%@",[urlString lastPathComponent]]];
		} else if ( [urlString hasPrefix:@"/poster"] ) {
			[string appendFormat:@"You uploaded:<br>\n"];
			[string appendFormat:@"<img src='/image/%@'>\n",[params objectForKey:@"myfile"]];
		} else {
			//	NSLog(@"get: %@ parameters: %@",urlString,params);
			[string appendFormat:@"<title>REST-Connect</title>"];
			[string appendFormat:@"libmicrohttpd and Objective-C running on Amazon EC2 for REST/Connect.<hr>\n" ];
			if ( [params count] ) {
				[string appendFormat:@"parameters:<br><ol>\n" ];
				for ( NSString *key in [params keyEnumerator] ) {
					[string appendFormat:@"<li>%@ = %@<br></li>\n",key,[params objectForKey:key]];
				}
				[string appendFormat:@"</ol>" ];
			}
			[string appendFormat:@"<form method='post' enctype='multipart/form-data' action='poster?param1=value1'>\n" ];
			//	[string appendFormat:@"First name: <input type='text' name='firstname' /><br />\n"];
			[string appendFormat:@"file: <input type='file' name='myfile'  /><br />\n"];
			[string appendFormat:@"First Name: <input type='text' name='name'  /><br />\n"];
			[string appendFormat:@"<input type='submit' /><br />\n"];
			[string appendFormat:@"</form>\n" ];
		}
		[string appendFormat:@"</body><html>\n"];
		return [string dataUsingEncoding:NSISOLatin1StringEncoding];
	}
}

-(NSData*)post:(NSString *)urlString parameters:(MPWPOSTProcessor*)params
{
	//	NSLog(@	"POSTed: %@",[[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease]);
	NSMutableDictionary *getParamterDict=[NSMutableDictionary dictionary];
	for ( NSString *key in [[params values] allKeys] ) {
		NSString *filename=[[params filenames] objectForKey:key];
		NSData *value = [[params values] objectForKey:key];
		
		if ( filename ) {
			NSLog(@"key: %@ filename: %@ file of size: %d",key,filename,[value length]);
			NSString *fullpath=[@"/tmp/fileUploads/" stringByAppendingPathComponent:filename];
			NSLog(@"will write file to '%@'",fullpath);
			BOOL success=[value writeToFile:fullpath atomically:YES];
			NSLog(@"success writing to '%@': %d",fullpath,success);
			NSString *cmd=[NSString stringWithFormat:@"mpack -d body.txt -s 'REST/Connect sent: %@' %@ '%@'",filename,fullpath,email];
			NSLog(@"will execute: '%@'",cmd);
			system([cmd UTF8String]);
			NSLog(@"did execute: %@",cmd);
			[getParamterDict setObject:filename forKey:key];
		} else {
			NSString *stringValue=[[[NSString alloc] initWithData:value encoding:NSISOLatin1StringEncoding] autorelease];
			NSLog(@"key: %@ value: %@",key,stringValue);
			[getParamterDict setObject:stringValue forKey:key];
			
		}
	}
	//	NSLog(@"POST keys: %@",[[params values] allKeys]);
	//	NSLog(@"POST filenames: %@",[[params filenames] allValues]);
	//	[[[params  values] objectForKey:@"myfile"] writeToFile:@"/tmp/POST.data" atomically:YES];
	return [self get:urlString parameters:getParamterDict];
}



@end
