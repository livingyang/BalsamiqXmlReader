//
//  TestRadioLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "TestRadioLayer.h"

#import "CCBalsamiqScene.h"
#import "CCBalsamiqLayer.h"
#import "TestWebViewLayer.h"
#import "TestLoadingBarLayer.h"

@implementation TestRadioLayer

@synthesize balsamiqLayer;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild:[self node]];
	
	// return the scene
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestWebViewLayer scene]]];
}

- (void)onNextClick:(id)sender
{
    NSLog(@"btn1 radio select item = %@", [self.balsamiqLayer getSelectedRadioByGroup:@"btn1"]);
    NSLog(@"btn2 radio select item = %@", [self.balsamiqLayer getSelectedRadioByGroup:@"btn2"]);
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestLoadingBarLayer scene]]];
}

-(id) init
{
	if( (self=[super init]))
	{
        self.balsamiqLayer = [CCBalsamiqLayer layerWithBalsamiqFile:@"test-radio.bmml"
                                                            eventHandle:self];
		[self addChild:self.balsamiqLayer];
	}
	return self;
}

@end
