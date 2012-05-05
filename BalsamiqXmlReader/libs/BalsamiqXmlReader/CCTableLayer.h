//
//  CCTableLayer.h
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCTableLayer : CCLayer
{
    CCLayerColor *colorLayer;
    CCLayerColor *tableAreaDebug;
    
    CCNode *cellContainer;
    CGPoint originCellContainerPos;
    CGRect containerRect;
    
	// Internal state of scrollLayer (scrolling or idle).
	int state_;
    
	// The x coord of initial point the user starts their swipe.
	CGPoint startSwipe_;
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// Holds the touch that started the scroll
	UITouch *scrollTouch_;
#endif
}

/** Calibration property. Minimum moving touch length that is enough
 * to cancel menu items and start scrolling a layer. 
 */
@property CGFloat minimumTouchLengthToSlide;

@property (nonatomic, readwrite) CGPoint scrollDirection;

@property BOOL isDebug;

- (void)addCell:(CCNode *)cell;

@end