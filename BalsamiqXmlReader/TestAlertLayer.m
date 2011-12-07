//
//  NextLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-15.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "TestAlertLayer.h"

#import "BalsamiqControlData.h"
#import "CCBalsamiqLayer.h"
#import "CCAlertLayer.h"
#import "CCBalsamiqScene.h"

#import "MainLayer.h"
#import "TestWebViewLayer.h"

@implementation TestAlertLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// add layer as a child to scene
	[scene addChild:[TestAlertLayer node]];
	
	// return the scene
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
																					 scene:[TestWebViewLayer scene]]];
}

- (void)onPopAlertClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"alert-yes-no.bmml"
                                       parentNode:self];
    
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Title"] setString:@"Pop Alert"];
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Message"] setString:@"onPopAlertClick"];
}

- (void)onShowAlertClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"alert-yes-no.bmml"
                                       parentNode:self
                                        showModal:kNormalShowModal];
    
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Title"] setString:@"Show Alert"];
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Message"] setString:@"onShowAlertClick"];
}

- (void)onYesClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"alert-yes-no.bmml"
                                       parentNode:self];
    
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Title"] setString:@"Pop Alert"];
    [[layer.balsamiqLayer.nameAndControlDic objectForKey:@"Message"] setString:@"onYesClick"];
}

- (void)onNoClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"test-alert.bmml"
												  eventHandle:self]];
	}
	return self;
}

@end
