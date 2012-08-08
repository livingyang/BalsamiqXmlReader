//
//  CCAlertLayer.m
//  TicTacToe
//
//  Created by lee living on 11-8-5.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCAlertLayer.h"
#import "CCBalsamiqLayer.h"
#import "CCMenuItemButton.h"
#import "BalsamiqReaderConfig.h"

@implementation CCAlertLayer

@synthesize balsamiqLayer;

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

- (void)runActionWithModal:(CCAlertLayerMode)modal
{
	switch (modal)
	{
		case CCAlertLayerPopMode:
		{
            self.balsamiqLayer.scale = 0.01f;
            [self.balsamiqLayer runAction:[CCSequence actions:
                                           [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.2 scale:1]],
                                           nil]];
		}break;
		default:
		{
		}break;
	}
}

////////////////////////////////////////////////////////
#pragma mark 继承函数
////////////////////////////////////////////////////////

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
													 priority:kCCMenuTouchPriority
											  swallowsTouches:YES];
	
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

- (id)initWithColor:(ccColor4B)color
      alertFileName:(NSString *)fileName
    eventHandleNode:(CCNode *)eventHandleNode
          showModal:(CCAlertLayerMode)modal
{
	self = [super initWithColor:color];
	if (self != nil)
	{
        balsamiqLayer = [CCBalsamiqLayer layerWithBalsamiqFile:fileName
                                                   eventHandle:eventHandleNode];
        balsamiqLayer.anchorPoint = ccp(0.5, 0.5);
        balsamiqLayer.position = ccp([CCDirector sharedDirector].winSize.width / 2,
                                     [CCDirector sharedDirector].winSize.height / 2);
        
        [self addChild:balsamiqLayer];
        
        [self runActionWithModal:modal];
	}
	return self;
}

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
	  showModal:(CCAlertLayerMode)modal
{
    CCAlertLayer *alert = [[[CCAlertLayer alloc] initWithColor:ccc4(0, 0, 0, [BalsamiqReaderConfig instance].alertOpacity)
                                                 alertFileName:fileName
                                               eventHandleNode:parentNode
                                                     showModal:modal] autorelease];
    [parentNode addChild:alert z:INT_MAX];
    return alert;
}

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
{
	return [CCAlertLayer showAlert:fileName
						parentNode:parentNode
						 showModal:CCAlertLayerNormalMode];
}

+ (void)removeAlertFromNode:(id)subNode
{
    [[CCAlertLayer getAlertLayerFromNode:subNode] removeFromParentAndCleanup:YES];
}

+ (CCAlertLayer *)getAlertLayerFromNode:(id)subNode
{
    while ([subNode isKindOfClass:[CCAlertLayer class]] == NO)
    {
        if ([subNode parent] == nil)
        {
            return nil;
        }
        
        subNode = [subNode parent];
    }
    
    return subNode;
}

@end
