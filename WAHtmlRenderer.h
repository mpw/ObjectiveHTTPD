//
//  WAHtmlRenderer.h
//  ObjectiveHTTPD
//
//  Created by Marcel Weiher on 6/23/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface WAHtmlRenderer : MPWFlattenStream {

}

-(void)startTag:(char*)tagName;
-(void)startTag:(char*)name attributes:attrs;
-(void)closeTag:(char*)tagName;
-(void)element:(char*)name content:content;
-(void)element:(char*)name content:content selector:(SEL)selector;
-(void)element:(char*)name attributes:attrs content:content;
-(void)element:(char*)name attributes:attrs  content:content selector:(SEL)selector;
-(void)anchor:textContent href:hrefUrl;

@end

@interface NSObject(renderOn)

-(void)renderOn:(WAHtmlRenderer*)renderer;

@end
