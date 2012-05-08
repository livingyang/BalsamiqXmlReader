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
#import "TestLinkLayer.h"

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

- (void)createCell:(int)count atTableLayer:(CCTableLayer *)tabLayer
{
    for (int i = 0; i < count; ++i)
    {
        CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                           eventHandle:self];
        cell.position = ccp(0, 100 * i);
        
        CCMenuItemImage *button = [cell getControlByName:@"Button"];
        button.tag = i;
        
        [tabLayer addCell:cell];
    }
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"6-test-scrolllayer.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        self.tableLayer = [layer getControlByName:@"table1"];
        
        [self createCell:4 atTableLayer:self.tableLayer];
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

- (void)onResetItemClick:(id)sender
{
    [self.tableLayer removeAllCell];
    
    [self createCell:3 atTableLayer:self.tableLayer];
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
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestLinkLayer scene]]];
}

@end
