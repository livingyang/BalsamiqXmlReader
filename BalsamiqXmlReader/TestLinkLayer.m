//
//  TestLinkLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestLinkLayer.h"
#import "TestScrollLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestLinkLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestLinkLayer node]];
    
	return scene;
}

- (id)init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"7-test-link-layer.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
	}
	return self;
}

#pragma mark -
#pragma mark layer navigation

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestScrollLayer scene]]];
}

- (void)onNextClick:(id)sender
{
}

@end
