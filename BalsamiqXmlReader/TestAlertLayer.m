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

#import "TestButtonLayer.h"
#import "TestWebViewLayer.h"

@implementation TestAlertLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[TestAlertLayer node]];
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestButtonLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestWebViewLayer scene]]];
}

- (void)onPopAlertClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"2.1-alert-yes-no.bmml"
                                       parentNode:self];
    
    [[layer.balsamiqLayer getControlByName:@"Title"] setString:@"Pop Alert"];
    [[layer.balsamiqLayer getControlByName:@"Message"] setString:@"onPopAlertClick"];
}

- (void)onShowAlertClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"2.1-alert-yes-no.bmml"
                                       parentNode:self
                                        showModal:kNormalShowModal];
    
    [[layer.balsamiqLayer getControlByName:@"Title"] setString:@"Show Alert"];
    [[layer.balsamiqLayer getControlByName:@"Message"] setString:@"onShowAlertClick"];
}

- (void)onYesClick:(id)sender
{
	CCAlertLayer *layer = [CCAlertLayer showAlert:@"2.1-alert-yes-no.bmml"
                                       parentNode:self];
    
    [[layer.balsamiqLayer getControlByName:@"Title"] setString:@"Pop Alert"];
    [[layer.balsamiqLayer getControlByName:@"Message"] setString:@"onYesClick"];
}

- (void)onNoClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"2-test-alert.bmml"
												  eventHandle:self]];
	}
	return self;
}

@end
