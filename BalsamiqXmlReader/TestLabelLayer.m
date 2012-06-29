//
//  TestLabelLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-6-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestLabelLayer.h"
#import "CCBalsamiqLayer.h"
#import "MainLayer.h"
#import "TestButtonLayer.h"

@implementation TestLabelLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[TestLabelLayer node]];
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[MainLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestButtonLayer scene]]];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"1.1-test-label.bmml"
												  eventHandle:self]];
	}
	return self;
}


@end
