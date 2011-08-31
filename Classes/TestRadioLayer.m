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

@implementation TestRadioLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild:[self node]];
	
	// return the scene
	return scene;
}

- (void)onRadioItemSelected:(CCMenuItemImage *)item withInfo:(NSString *)info
{
	NSLog(@"item = %@ clicked, info = %@", item, info);
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestWebViewLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	//	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
	//																					 scene:[TestAlertLayer scene]]];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"test-radio.bmml"
												  eventHandle:self
												createdHandle:self]];
	}
	return self;
}

@end
