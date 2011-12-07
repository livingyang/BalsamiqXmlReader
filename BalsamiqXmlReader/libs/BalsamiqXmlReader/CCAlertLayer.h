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

@class CCBalsamiqLayer;
@interface CCAlertLayer : CCLayerColor
{
    CCBalsamiqLayer *balsamiqLayer;
}

@property (nonatomic, readonly) CCBalsamiqLayer *balsamiqLayer;

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode;

+ (id)showAlert:(NSString *)fileName
	 parentNode:(CCNode *)parentNode
	  showModal:(AlertShowModal)modal;

+ (void)removeAlertFromNode:(id)subNode;

+ (CCAlertLayer *)getAlertLayerFromNode:(id)subNode;

@end
