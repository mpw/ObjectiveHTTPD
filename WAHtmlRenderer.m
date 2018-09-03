//
//  WAHtmlRenderer.m
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 6/23/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
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
	[self.target writeElementName:"b" attributes:nil contents:textContent];
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
    [self.target beginStartTag:"a"];
    [self.target writeAttribute:@"href" value:hrefUrl];
    [self.target endStartTag:"a" single:NO];
    [self.target writeString:textContent];
    [self.target writeCloseTag:"a"];
//	[self element:"a" attributes:[NSString stringWithFormat:@"href='%@'",hrefUrl] content:textContent];
}

-(void)startTag:(char*)name attributes:attrs 
{
    [self.target writeStartTag:name attributes:attrs single:NO];
}

-(void)startTag:(char*)name 
{
    [self.target writeStartTag:name attributes:nil single:NO];
}

-(void)closeTag:(char*)name 
{
    [self.target writeCloseTag:name];
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
