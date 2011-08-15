//
//  NextLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-15.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "NextLayer.h"

#import "BalsamiqControlData.h"
#import "CCBalsamiqLayer.h"
#import "BalsamiqReaderHelper.h"
#import "CCAlertLayer.h"

#import "HelloWorldLayer.h"

@implementation NextLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// add layer as a child to scene
	[scene addChild:[NextLayer node]];
	
	// return the scene
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)onButtonClick:(id)sender
{
	[CCAlertLayer showAlert:getBalsamiqData(@"alert-yes-no.bmml")
				 parentNode:self];
}

- (void)onYesClick:(id)sender
{
	[CCAlertLayer showAlert:getBalsamiqData(@"alert-yes-no.bmml")
				 parentNode:self];
}

- (void)onNoClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqData:getBalsamiqData(@"next.bmml")
												  eventHandle:self]];
	}
	return self;
}

@end
