//
//  TestRadioTableLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-6-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestRadioTableLayer.h"
#import "TestLinkLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestRadioTableLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestRadioTableLayer node]];
    
	return scene;
}

- (id)init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"8-test-radio-table.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        [[[layer getControlByName:@"page1"] getControlByName:@"title"] setString:@"page1"];
        [[[layer getControlByName:@"page2"] getControlByName:@"title"] setString:@"page2"];
        [[[layer getControlByName:@"page3"] getControlByName:@"title"] setString:@"page3"];
        
        [layer selectRadioItem:@"radio_Page_3"];
        NSDictionary *radioTable = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [layer getControlByName:@"page1"], @"radio_Page_1",
                                    [layer getControlByName:@"page2"], @"radio_Page_2",
                                    [layer getControlByName:@"page3"], @"radio_Page_3",
                                    nil];
        [[layer getRadioManagerByGroup:@"Page"] setItemAndSelectLayer:radioTable];
	}
	return self;
}

#pragma mark -
#pragma mark layer navigation

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestLinkLayer scene]]];
}

- (void)onNextClick:(id)sender
{
}

@end
