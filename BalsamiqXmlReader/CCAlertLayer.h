//
//  CCAlertLayer.h
//  TicTacToe
//
//  Created by lee living on 11-8-5.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAlertLayer : CCLayerColor
{
	NSDictionary *labelInfoDic_;
	NSDictionary *buttonInfoDic_;
}

@property (nonatomic, assign) NSDictionary *labelInfoDic;
@property (nonatomic, assign) NSDictionary *buttonInfoDic;

+ (void)showAlert:(NSArray *)balsamiqData parentNode:(CCNode *)parentNode;

+ (void)showAlert:(NSArray *)balsamiqData
	   parentNode:(CCNode *)parentNode
		labelInfo:(NSDictionary *)labelInfoDic
	   buttonInfo:(NSDictionary *)buttonInfoDic;

+ (void)removeAlertFromNode:(id)subNode;

+ (CCAlertLayer *)getAlertLayerFromNode:(id)subNode;

@end
