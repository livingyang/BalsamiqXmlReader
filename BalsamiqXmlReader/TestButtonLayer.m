//
//  TestButtonLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-6-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestButtonLayer.h"
#import "TestLabelLayer.h"
#import "TestAlertLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestButtonLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[TestButtonLayer node]];
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestLabelLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestAlertLayer scene]]];
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"1.2-test-button.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        [[layer getControlByName:@"AllDisable"] setIsEnabled:NO];
        [[layer getControlByName:@"OneDisable"] setIsEnabled:NO];
	}
	return self;
}

@end
