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

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestRadioLayer scene]]];
}

- (void)onNextClick:(id)sender
{
//	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
//																					 scene:[TestAlertLayer scene]]];
}

- (void)onLoadingAlertClick:(id)sender
{
	[CCAlertLayer showAlert:@"alert-loading.bmml"
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
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"test-loadingbar.bmml"
												  eventHandle:self
												createdHandle:self]];
	}
	return self;
}

@end
