//
//  CCTableLayer.h
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
 
 --------------------------------D
 |                               |
 |                               |
 |     -------------------C      |
 |     |                  |      |
 |     |                  |      |
 |     |    LayerRect     |      |
 |     |                  |      |
 |     |                  |      |
 |     B-------------------      |
 |                               |
 |      CellContainerRect        |
 |                               |
 A-------------------------------|
 
 */

@interface CCTableLayer : CCLayer
{
	// Internal state of scrollLayer (scrolling or idle).
	int state_;
    
	// The x coord of initial point the user starts their swipe.
	CGPoint startSwipe_;
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// Holds the touch that started the scroll
	UITouch *scrollTouch_;
#endif
    
    CCNode *cellContainer;
    CGPoint originCellContainerPos;
    
    // touch start position
    CGPoint startTouchCellContainerPos;
    
    // inertia
    NSTimeInterval lastTouchTimeStamp;
    CGPoint vectorInertia;
}

@property (nonatomic, assign) id<CCTouchOneByOneDelegate> delegate;

/** Calibration property. Minimum moving touch length that is enough
 * to cancel menu items and start scrolling a layer. 
 */
@property CGFloat minimumTouchLengthToSlide;

@property BOOL isDebug;
@property BOOL isMenuItemContainsEnable;  // NO - Intersect enable

// cellContain move vector
@property CGPoint vectorMove;
@property float maxDistance;
@property (nonatomic, readwrite) float curDistance;
@property (nonatomic, readonly) CCNode *cellContainer;

- (void)setCellContainer:(CCNode *)container;
- (void)setCellContainer:(CCNode *)container autoSetWithVectorMove:(CGPoint)vecMove;

- (void)resetMaxDistance;

// 未实现
- (float)getCellDistance:(CCNode *)cell;

@end

@protocol CCTableLayerDelegate <NSObject>

- (void)onMoveDone:(CCTableLayer *)tableLayer;

@end

@interface CCTableMenu : CCMenu {
    
}

@end
