//
//  TestTabsLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-6-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestTabsLayer.h"
#import "TestLinkLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestTabsLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestTabsLayer node]];
    
	return scene;
}

- (id)init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"8-test-tabs.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        [layer selectRadioItem:@"radio_Page_1"];
        
        [[[layer getControlByName:@"tab_Page_1"] getControlByName:@"title"] setString:@"page1"];
        [[[layer getControlByName:@"tab_Page_2"] getControlByName:@"title"] setString:@"page2"];
        [[[layer getControlByName:@"tab_Page_3"] getControlByName:@"title"] setString:@"page3"];
        
        
        [[layer getRadioManagerByGroup:@"CustomPage"] setItemName:@"radio_CustomPage_1"
                                                          withTab:[layer getControlByName:@"page1"]];
        [[layer getRadioManagerByGroup:@"CustomPage"] setItemName:@"radio_CustomPage_2"
                                                          withTab:[layer getControlByName:@"page2"]];
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
