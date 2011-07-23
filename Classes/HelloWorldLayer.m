//
//  HelloWorldLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright LieHuo Tech 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#import "BalsamiqControlData.h"
#import "CCLayer+BalsamiqParser.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]))
	{
		NSString *xmlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.bmml"];
		
		NSArray *array = [BalsamiqControlData parseData:[NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil]];
		
		for (id ele in array)
		{
			NSLog(@"%@", ele);
		}
		
		balsamiqFontName = @"Vanilla.ttf";
		
		CCLayer *layer = [CCLayer layerWithBalsamiqData:array eventHandle:self];
		
		[self addChild:layer];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
