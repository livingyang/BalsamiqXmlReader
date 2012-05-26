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
    NSLog(@"Btn1 radio select item = %@", [self.balsamiqLayer getRadioManagerByGroup:@"Btn1"].selectedItemInfo);
    NSLog(@"Btn2 radio select item = %@", [self.balsamiqLayer getRadioManagerByGroup:@"Btn2"].selectedItemInfo);
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestLoadingBarLayer scene]]];
}

- (void)onBtn1RadioSelected:(NSString *)itemName
{
    NSLog(@"TestRadioLayer#onBtn1RadioSelected item name = %@", itemName);
}

- (void)onBtn2RadioSelected:(NSString *)itemName
{
    NSLog(@"TestRadioLayer#onBtn2RadioSelected item name = %@", itemName);
}

- (void)onSelect_radio_Btn2_2:(id)sender
{
    NSLog(@"TestRadioLayer#onSelect_radio_Btn2_2 item = %@", sender);
}

-(id) init
{
	if( (self=[super init]))
	{
        self.balsamiqLayer = [CCBalsamiqLayer layerWithBalsamiqFile:@"4-test-radio.bmml"
                                                            eventHandle:self];
		[self addChild:self.balsamiqLayer];
        
        [self.balsamiqLayer selectRadioItem:@"radio_Btn2_2"];
	}
	return self;
}

@end
