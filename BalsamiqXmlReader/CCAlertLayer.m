//
//  CCAlertLayer.m
//  TicTacToe
//
//  Created by lee living on 11-8-5.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCAlertLayer.h"
#import "CCBalsamiqLayer.h"

@implementation CCAlertLayer

@synthesize labelInfoDic;
@synthesize buttonInfoDic;

- (void)onButtonCreated:(CCMenuItemButton *)button name:(NSString *)name
{
	NSString *text = [self.buttonInfoDic objectForKey:name];
	
	if (text != nil)
	{
		[button setText:text];
	}
}

- (void)onImageCreated:(CCSprite *)image name:(NSString *)name
{
}

- (void)onLabelCreated:(CCLabelTTF *)label name:(NSString *)name
{
	NSString *text = [self.labelInfoDic objectForKey:name];
	
	if (text != nil)
	{
		[label setString:text];
	}
}

- (void)onTextInputCreated:(UITextField *)textInput name:(NSString *)name
{}


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

+ (void)showAlert:(NSArray *)balsamiqData
	   parentNode:(CCNode *)parentNode
		labelInfo:(NSDictionary *)labelInfoDic
	   buttonInfo:(NSDictionary *)buttonInfoDic
{
	if (balsamiqData == nil || parentNode == nil)
	{
		return;
	}
	
	id action = [CCScaleTo actionWithDuration:1.2 scale:1];
	action = [CCEaseElasticOut actionWithAction:action];
	
	ccColor4B color = ccc4(0, 0, 0, 50);
	CCAlertLayer *alert = [CCAlertLayer layerWithColor:color];
	alert.labelInfoDic = labelInfoDic;
	alert.buttonInfoDic = buttonInfoDic;
	
	CCLayer *layer = [CCBalsamiqLayer layerWithBalsamiqData:balsamiqData
												eventHandle:parentNode
											  createdHandle:alert];
	layer.scale = 0;
	layer.anchorPoint = ccp(0.5, 0.5);
	layer.position = ccp([CCDirector sharedDirector].winSize.width / 2,
						 [CCDirector sharedDirector].winSize.height / 2);
	
	[layer runAction:action];
	[alert addChild:layer];
	
	[parentNode addChild:alert z:INT_MAX];
}

+ (void)showAlert:(NSArray *)balsamiqData parentNode:(CCNode *)parentNode
{
	return [CCAlertLayer showAlert:balsamiqData
						parentNode:parentNode
						 labelInfo:nil
						buttonInfo:nil];
	if (balsamiqData == nil || parentNode == nil)
	{
		return;
	}
	
	id action = [CCScaleTo actionWithDuration:1.2 scale:1];
	action = [CCEaseElasticOut actionWithAction:action];
	
	ccColor4B color = ccc4(0, 0, 0, 50);
	CCAlertLayer *alert = [CCAlertLayer layerWithColor:color];
	CCLayer *layer = [CCBalsamiqLayer layerWithBalsamiqData:balsamiqData
												eventHandle:parentNode
											  createdHandle:alert];
	layer.scale = 0;
	layer.anchorPoint = ccp(0.5, 0.5);
	layer.position = ccp([CCDirector sharedDirector].winSize.width / 2,
						 [CCDirector sharedDirector].winSize.height / 2);
	
	[layer runAction:action];
	[alert addChild:layer];
	
	[parentNode addChild:alert z:INT_MAX];
}

+ (void)removeAlertFromNode:(id)subNode
{
	CCAlertLayer *alert = [CCAlertLayer getAlertLayerFromNode:subNode];
	
	[alert.parent removeChild:alert cleanup:YES];
}

+ (CCAlertLayer *)getAlertLayerFromNode:(id)subNode
{
	if (subNode == nil || [subNode isKindOfClass:[CCNode class]] == NO)
	{
		return nil;
	}
	
	while (subNode != nil)
	{
		if ([subNode isKindOfClass:[CCAlertLayer class]])
		{
			break;
		}
		
		subNode = [subNode parent];
	}
	
	return subNode;
}

@end
