//
//  TestLoadingBarLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "TestLoadingBarLayer.h"
#import "TestRadioLayer.h"
#import "CCAlertLayer.h"
#import "CCBalsamiqLayer.h"

#import "TestScrollLayer.h"

@implementation TestLoadingBarLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild:[self node]];
	
	// return the scene
	return scene;
}

#pragma mark -
#pragma mark layer navigation

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestRadioLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestScrollLayer scene]]];
}

- (void)onLoadingAlertClick:(id)sender
{
	[CCAlertLayer showAlert:@"5.1-alert-loading.bmml"
				 parentNode:self];
}

- (void)onCancleClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"5-test-loadingbar.bmml"
												  eventHandle:self]];
	}
	return self;
}

@end
