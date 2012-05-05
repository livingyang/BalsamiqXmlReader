//
//  TestScrollLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestScrollLayer.h"
#import "CCBalsamiqLayer.h"
#import "CCTableLayer.h"
#import "TestLoadingBarLayer.h"

@implementation TestScrollLayer

@synthesize tableLayer;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestScrollLayer node]];

	return scene;
}

- (void)onButtonClick:(id)sender
{
    NSLog(@"CCTableLayer#onButtonClick sender tag = %d", [sender tag]);
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"6-test-scrolllayer.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        self.tableLayer = [layer getControlByName:@"table1"];
        
        for (int i = 0; i < 4; ++i)
        {
            CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                               eventHandle:self];
            cell.position = ccp(0, 100 * i);
            
            CCMenuItemImage *button = [cell getControlByName:@"Button"];
            button.tag = i;
            
            [self.tableLayer addCell:cell];
        }
	}
	return self;
}

- (void)onSetDebugClick:(id)sender
{
    self.tableLayer.isDebug = !self.tableLayer.isDebug;
}

- (void)onSetDirectionClick:(id)sender
{
    self.tableLayer.scrollDirection = ccp(0, 1);
}

#pragma mark -
#pragma mark layer navigation

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestLoadingBarLayer scene]]];
}

- (void)onNextClick:(id)sender
{
//	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
//																					 scene:[TestAlertLayer scene]]];
}

@end
