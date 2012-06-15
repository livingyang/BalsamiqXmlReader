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
#import "CCMenuItemButton.h"

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
    
    if ([sender tag] == 0)
    {
        CCBalsamiqLayer *layer = [CCBalsamiqLayer getBalsamiqLayerFromChild:sender];
        const int addCount = 4;
        for (int i = 0; i < addCount; ++i)
        {
            CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                               eventHandle:self];
            
            cell.position = layer.position;
            layer.position = ccp(layer.position.x, layer.position.y - cell.contentSize.height);
            
            [[cell getControlByName:@"Button"] setTag:-1];
            [[cell getControlByName:@"title"] setString:@"New cell!!"];
            
            [tableLayer.cellContainer addChild:cell];
        }
        
        tableLayer.maxDistance = [tableLayer getMaxDistanceFromContainer:tableLayer.cellContainer];
    }
}


- (void)createCell:(int)count
      atTableLayer:(CCTableLayer *)tabLayer
    withVectorMove:(CGPoint)vectorMove
{
    CCNode *container = [CCNode node];
    
    for (int i = 0; i < count; ++i)
    {
        CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                           eventHandle:self];
        
        cell.position = ccpCompMult(vectorMove, ccpMult(ccpFromSize(cell.contentSize), i));
        
        [[cell getControlByName:@"Button"] setTag:i];
        [[cell getControlByName:@"title"] setString:[NSString stringWithFormat:@"cell id = %d", i]];
        if (i == 0)
        {
            [[cell getControlByName:@"Button"] setText:@"Add Cell!!"];
        }
        
        [container addChild:cell];
    }
    
    
    [tabLayer setCellContainer:container autoSetWithVectorMove:vectorMove];
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"6-test-scrolllayer.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        self.tableLayer = [layer getControlByName:@"table1"];
        
        [self createCell:2 atTableLayer:self.tableLayer withVectorMove:ccp(0, 1)];
	}
	return self;
}

- (void)onSetDebugClick:(id)sender
{
    self.tableLayer.isDebug = !self.tableLayer.isDebug;
}

- (void)onResetItemClick:(id)sender
{
    [self createCell:4 atTableLayer:self.tableLayer withVectorMove:ccp(-1, 0)];
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
