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
#import "CCSprite+LoadingBar.h"
#import "CCBalsamiqLayer.h"

#import "TestScrollLayer.h"

@implementation TestLoadingBarLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[self node]];
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
	CCAlertLayer *alert = [CCAlertLayer showAlert:@"5.1-alert-loading.bmml"
                                       parentNode:self];
    [[alert.balsamiqLayer getControlByName:@"image_loading"] loadingWithInterval:1.0f / 12 angle:360.0f / 12];
}

- (void)onStopLoadingClick:(id)sender
{
    [[layer getControlByName:@"image_loading1"] stopLoading];
    [[layer getControlByName:@"image_loading2"] stopLoading];
    [[layer getControlByName:@"image_loading3"] stopLoading];
}

- (void)onCancleClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

-(id) init
{
	if( (self=[super init]))
	{
        layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"5-test-loadingbar.bmml"
                                           eventHandle:self];
		[self addChild:layer];
        
        [[layer getControlByName:@"image_loading1"] loadingWithInterval:1];
        [[layer getControlByName:@"image_loading2"] loadingWithInterval:1.0f / 12 angle:360.0f / 12];
        [[layer getControlByName:@"image_loading3"] loadingWithInterval:1.0f / 12 angle:360.0f / 12];
	}
	return self;
}

@end
