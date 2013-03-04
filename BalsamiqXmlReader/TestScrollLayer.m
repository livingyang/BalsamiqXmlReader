//
//  TestScrollLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestScrollLayer.h"
#import "CCBalsamiqLayer.h"
#import "CCAlertLayer.h"
#import "TestLoadingBarLayer.h"
#import "TestLinkLayer.h"
#import "CCMenuItemButton.h"

@implementation TestScrollLayer

@synthesize tableVLayer;
@synthesize tableHLayer;

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
            [[cell getControlByName:@"title"] setString:[NSString stringWithFormat:@"New cell %d", arc4random()]];
            
            [tableVLayer.cellContainer addChild:cell];
        }
        
        [tableVLayer resetMaxDistance];
    }
}

- (void)createHorizontalCell:(int)count
{
    CCNode *container = [CCNode node];
    
    for (int i = 2; i < count + 2; ++i)
    {
        CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                           eventHandle:self];
        
        cell.position = ccpCompMult(ccp(-1, 0), ccpMult(ccpFromSize(cell.contentSize), i));
        
        [[cell getControlByName:@"Button"] setTag:i];
        [[cell getControlByName:@"title"] setString:[NSString stringWithFormat:@"cell id = %d", i]];
        
        [container addChild:cell];
    }
    
    
    [self.tableHLayer setCellContainer:container autoSetWithVectorMove:ccp(-1, 0)];
}

- (void)createVerticalCell:(int)count
{
    CCNode *container = [CCNode node];
    
    for (int i = 0; i < count; ++i)
    {
        CCBalsamiqLayer *cell = [CCBalsamiqLayer layerWithBalsamiqFile:@"6.1-cell.bmml"
                                                           eventHandle:self];
        
        cell.position = ccpCompMult(ccp(0, 1), ccpMult(ccpFromSize(cell.contentSize), i));
        
        [[cell getControlByName:@"Button"] setTag:i];
        [[cell getControlByName:@"title"] setString:[NSString stringWithFormat:@"cell id = %d", i]];
        if (i == 0)
        {
            [[cell getControlByName:@"Button"] setText:@"Add Cell!!"];
        }
        
        [container addChild:cell];
    }
    
    [self.tableVLayer setCellContainer:container autoSetWithVectorMove:ccp(0, 1)];
}

- (void)onMoveDone:(CCTableLayer *)table
{
    NSLog(@"TestScrollLayer#onMoveDone %@", table);
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"6-test-scrolllayer.bmml"
                                                            eventHandle:self];
		[self addChild:layer];
        
        self.tableVLayer = [layer getControlByName:@"tableV"];
        self.tableVLayer.delegate = self;
        self.tableHLayer = [layer getControlByName:@"tableH"];
        self.tableHLayer.delegate = self;
        
        [self createVerticalCell:2];
        [self createHorizontalCell:10];
	}
	return self;
}

- (void)onSetDebugClick:(id)sender
{
    self.tableVLayer.isDebug = !self.tableVLayer.isDebug;
    self.tableHLayer.isDebug = self.tableVLayer.isDebug;
}

- (void)onSetPositionClick:(id)sender
{
//    CCBalsamiqLayer *randomCell = [self.tableLayer.cellContainer.children objectAtIndex:
//                                   arc4random() % self.tableLayer.cellContainer.children.count];
//    NSLog(@"randomCell title = %@", [[randomCell getControlByName:@"title"] string]);
//    self.tableLayer.curDistance = [self.tableLayer getCellDistance:randomCell];
}

- (void)onResetItemClick:(id)sender
{
    [CCAlertLayer showAlert:@"2.1-alert-yes-no.bmml" parentNode:self];
}

- (void)onYesClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

- (void)onNoClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
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
