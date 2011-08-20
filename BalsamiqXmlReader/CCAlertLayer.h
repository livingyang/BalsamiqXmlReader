//
//  CCAlertLayer.h
//  TicTacToe
//
//  Created by lee living on 11-8-5.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	kNormalShowModal,
	kPopAlertModal,
} AlertShowModal;

@interface CCAlertLayer : CCLayerColor
{
	NSDictionary *labelInfoDic_;
	NSDictionary *buttonInfoDic_;
	
	id parentNode_;
}

@property (nonatomic, assign) NSDictionary *labelInfoDic;
@property (nonatomic, assign) NSDictionary *buttonInfoDic;
@property (nonatomic, assign) id parentNode;

+ (void)showAlert:(NSString *)fileName
	   parentNode:(CCNode *)parentNode;

+ (void)showAlert:(NSString *)fileName
	   parentNode:(CCNode *)parentNode
		showModal:(AlertShowModal)modal;

+ (void)showAlert:(NSString *)fileName
	   parentNode:(CCNode *)parentNode
		labelInfo:(NSDictionary *)labelInfoDic
	   buttonInfo:(NSDictionary *)buttonInfoDic;

+ (void)showAlert:(NSString *)fileName
	   parentNode:(CCNode *)parentNode
		showModal:(AlertShowModal)modal
		labelInfo:(NSDictionary *)labelInfoDic
	   buttonInfo:(NSDictionary *)buttonInfoDic;

+ (void)removeAlertFromNode:(id)subNode;

+ (CCAlertLayer *)getAlertLayerFromNode:(id)subNode;

@end
