//
//  MPWFibServer.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 12/18/13.
//
//

#import "MPWFibServer.h"

@interface NSObject(shutupthecompileragain)

-fib;
-asData;

@end

@implementation MPWFibServer

-(NSData*)get:(NSString *)urlString parameters:(NSDictionary*)params
{
    urlString=[urlString lastPathComponent];
    NSNumber *n=[NSNumber numberWithInt:[urlString intValue]];
    NSNumber *fib=[n fib];
    return [[fib stringValue] asData];
    
}

@end
