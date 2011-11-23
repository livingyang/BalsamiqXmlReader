//
//  CCAlertLayer.m
//  TicTacToe
//
//  Created by lee living on 11-8-5.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCAlertLayer.h"
#import "BalsamiqReaderCreateDelegate.h"
#import "CCBalsamiqLayer.h"

@implementation CCAlertLayer

@synthesize labelInfoDic;
@synthesize buttonInfoDic;
@synthesize parentNode;

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

+ (CCAction *)getShowAction:(AlertShowModal)modal
{
	switch (modal)
	{
		case kPopAlertModal:
		{
			return [CCSequence actions:
					[CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.2 scale:1]],
					 nil];
		}break;
		default:
		{
			return [CCScaleTo actionWithDuration:0 scale:1.0f];
		}break;
	}
}

////////////////////////////////////////////////////////
#pragma mark 控件创建函数
////////////////////////////////////////////////////////

- (void)onButtonCreated:(CCMenuItemButton *)button name:(NSString *)name
{
	NSString *text = [self.buttonInfoDic objectForKey:name];
	
	if (text != nil)
	{
		[button setText:text];
	}
	
	if ([self.parentNode respondsToSelector:@selector(onButtonCreated:name:)])
	{
		[self.parentNode onButtonCreated:button name:name];
	}
}

- (void)onImageCreated:(CCSprite *)image name:(NSString *)name
{
	if ([self.parentNode respondsToSelector:@selector(onImageCreated:name:)])
	{
		[self.parentNode onImageCreated:image name:name];
	}
}

- (void)onLabelCreated:(CCLabelTTF *)label name:(NSString *)name
{
	NSString *text = [self.labelInfoDic objectForKey:name];
	
	if (text != nil)
	{
		[label setString:text];
	}
	
	if ([self.parentNode respondsToSelector:@selector(onLabelCreated:name:)])
	{
		[self.parentNode onLabelCreated:label name:name];
	}
}

- (void)onTextInputCreated:(UITextField *)textInput name:(NSString *)name
{
	
	if ([self.parentNode respondsToSelector:@selector(onTextInputCreated:name:)])
	{
		[self.parentNode onTextInputCreated:textInput name:name];
	}
}

- (void)onWebViewCreated:(UIWebView *)webView name:(NSString *)name
{
	if ([self.parentNode respondsToSelector:@selector(onWebViewCreated:name:)])
	{
		[self.parentNode onWebViewCreated:webView name:name];
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

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
	  showModal:(AlertShowModal)modal
	  labelInfo:(NSDictionary *)labelInfoDic
	 buttonInfo:(NSDictionary *)buttonInfoDic
{
	if (fileName == nil || parentNode == nil)
	{
		return nil;
	}
	
	ccColor4B color = ccc4(0, 0, 0, 50);
	CCAlertLayer *alert = [CCAlertLayer layerWithColor:color];
	alert.parentNode = parentNode;
	alert.labelInfoDic = labelInfoDic;
	alert.buttonInfoDic = buttonInfoDic;
	
	CCLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:fileName
												eventHandle:parentNode
											  createdHandle:alert];
	layer.scale = 0;
	layer.anchorPoint = ccp(0.5, 0.5);
	layer.position = ccp([CCDirector sharedDirector].winSize.width / 2,
						 [CCDirector sharedDirector].winSize.height / 2);
	
	[alert addChild:layer];
	
	[parentNode addChild:alert z:INT_MAX];
	
	[layer runAction:[CCAlertLayer getShowAction:modal]];
	
	return alert;
}

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
	  labelInfo:(NSDictionary *)labelInfoDic
	 buttonInfo:(NSDictionary *)buttonInfoDic
{
	return [CCAlertLayer showAlert:fileName
						parentNode:parentNode
						 showModal:kPopAlertModal
						 labelInfo:labelInfoDic
						buttonInfo:buttonInfoDic];
}

+ (id)showAlert:(NSString *)fileName parentNode:(CCNode *)parentNode
{
	return [CCAlertLayer showAlert:fileName
						parentNode:parentNode
						 showModal:kPopAlertModal
						 labelInfo:nil
						buttonInfo:nil];
}

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
	  showModal:(AlertShowModal)modal
{
	return [CCAlertLayer showAlert:fileName
						parentNode:parentNode
						 showModal:modal
						 labelInfo:nil
						buttonInfo:nil];
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
