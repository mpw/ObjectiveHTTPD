//
//  WAHtmlRenderer.m
//  MPWSideweb
//
//  Created by Marcel Weiher on 6/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WAHtmlRenderer.h"
#import <ObjectiveXML/MPWXmlGeneratorStream.h>


@implementation WAHtmlRenderer

-(SEL)streamWriterMessage
{
	return @selector(renderOn:);
}

+defaultTarget
{
	return [MPWXmlGeneratorStream stream];
}

-(void)bold:textContent
{
	[target writeElementName:"b" attributes:nil contents:textContent];
}

-(void)element:(char*)name attributes:attributes content:content selector:(SEL)selector
{
//	NSLog(@"element with contents and selector");
	[self startTag:name attributes:attributes];
//	NSLog(@"did start, will do  content");
	[content performSelector:selector withObject:self];
//	NSLog(@"did  content");
//	objc_msgSend( content, selector, self );
	[self closeTag:name];
}

-(void)element:(char*)name content:content selector:(SEL)selector
{
	[self element:name attributes:nil content:content selector:selector];
}

-(void)element:(char*)name attributes:attrs content:content 
{
//	SEL msg = [self streamWriterMessage];
//	NSLog(@"will forward");
	[self element:name attributes:attrs content:content selector:streamWriterMessage];
}

-(void)element:(char*)name content:content
{
	[self element:name content:content selector:[self streamWriterMessage]];
}

-(void)anchor:textContent href:hrefUrl
{
    [target beginStartTag:"a"];
    [target writeAttribute:@"href" value:hrefUrl];
    [target endStartTag:"a" single:NO];
    [target writeString:textContent];
    [target writeCloseTag:"a"];
//	[self element:"a" attributes:[NSString stringWithFormat:@"href='%@'",hrefUrl] content:textContent];
}

-(void)startTag:(char*)name attributes:attrs 
{
    [target writeStartTag:name attributes:attrs single:NO];
}

-(void)startTag:(char*)name 
{
    [target writeStartTag:name attributes:nil single:NO];
}

-(void)closeTag:(char*)name 
{
    [target writeCloseTag:name];
}

-result { return [self finalTarget];  }
-resultString { return [[self result] stringValue];  }


@end

@implementation NSObject(renderOn)

-(void)renderOn:(WAHtmlRenderer*)renderer
{
	[renderer writeNSObject:self];
}

@end



@implementation WAHtmlRenderer(testing)

+(void)testBoldNews
{
	id stream=[self stream];
	[stream bold:@"News"];
	id result=[stream resultString];
	IDEXPECT( result, @"<b>News</b>", @"Result of doing bold:'news'");
}

+(void)testAnchor
{
	id stream=[self stream];
	[stream anchor:@"Products" href:@"Products.html"];
	id result=[stream resultString];
	IDEXPECT( result, @"<a href=\"Products.html\">Products</a>", @"Result of doing anchor:'Products' :'Products.html'");
}

+(void)testTagConstruction
{
	id stream=[self stream];
	[stream startTag:"html" attributes:nil];
	[stream closeTag:"html"];
	id result=[stream resultString];
	IDEXPECT( result, @"<html></html>", @"Result of empty html element");
}

+(void)testContent
{
	WAHtmlRenderer *stream=[self stream];
	[stream element:"b" attributes:@"attr='value'" content:@"some content"];
	IDEXPECT( [stream resultString] , @"<b attr='value'>some content</b>", @"generic content" );

}

+(NSArray*)testSelectors
{
	return [NSArray arrayWithObjects:
		@"testBoldNews",
		@"testAnchor",
		@"testTagConstruction",
		@"testContent",
		nil];
}

@end