//
//  CCTableLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCTableLayer.h"

enum 
{
	kCCScrollLayerStateIdle,
	kCCScrollLayerStateSliding,
};

#define TAG_MOVE_BACK (12345)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers
{
	return targetedHandlers;
}

@end

@implementation CCMenuItemSprite (TableLayerBoundEnable)

- (BOOL)isEnabled
{
    for (CCNode *nodeParent = self;
         nodeParent != nil;
         nodeParent = nodeParent.parent)
    {
        if ([nodeParent isKindOfClass:[CCTableLayer class]])
        {
            CGPoint pointInTable = [self convertToWorldSpace:CGPointZero];
            pointInTable = [nodeParent convertToNodeSpace:pointInTable];
            
            CGRect tableRect = {CGPointZero, nodeParent.contentSize};
            CGRect selfRect = {pointInTable, self.contentSize};
            
            return CGRectContainsRect(tableRect, selfRect) && super.isEnabled;
        }
    }
    
    return super.isEnabled;
}

@end

#endif

@implementation CCTableLayer

@synthesize scrollDirection;
@synthesize minimumTouchLengthToSlide;
@synthesize isDebug;

- (id)init
{
    self = [super init];
	if (self != nil)
    {
        self.isTouchEnabled = YES;
		self.isRelativeAnchorPoint = YES;
        
        containerRect = CGRectZero;
        scrollDirection = CGPointZero;
        maxDisplayRect = CGRectZero;
        
        cellContainer = [CCNode node];
        [self addChild:cellContainer];
    }
    
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void) visit
{
    if (!self.visible)
    {
        return;
    }
    
    glEnable(GL_SCISSOR_TEST);
    float x = self.position.x - self.anchorPoint.x * self.contentSize.width;
    float y = self.position.y - self.anchorPoint.y * self.contentSize.height;
    
    glScissor(x * CC_CONTENT_SCALE_FACTOR(),
              y * CC_CONTENT_SCALE_FACTOR(),
              self.contentSize.width * CC_CONTENT_SCALE_FACTOR(),
              self.contentSize.height * CC_CONTENT_SCALE_FACTOR());   
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

- (CGRect)getCellContainerInTableLayer:(CGPoint)cellContainerPosition
{
    return (CGRect){ccpAdd(cellContainerPosition, containerRect.origin), containerRect.size};
}

- (void)draw
{
    if (isDebug)
    {
        glDisable(GL_SCISSOR_TEST);
        
        glColor4ub(100, 100, 100, 100);
        ccDrawSolidRect(CGPointZero, ccp(self.contentSize.width, self.contentSize.height));
        
        glColor4ub(100, 0, 0, 100);
        CGRect rect = [self getCellContainerInTableLayer:cellContainer.position];
        
        ccDrawSolidRect(rect.origin, ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
        
        glEnable(GL_SCISSOR_TEST);
    }
}

- (CGPoint)centerContainerPos
{
    CGPoint offsetPos = ccp((self.contentSize.width - containerRect.size.width) / 2,
                            (self.contentSize.height - containerRect.size.height) / 2);
    
    return ccpSub(offsetPos, containerRect.origin);
}

- (void)updateContainerRect:(CGRect)rect
{
    containerRect = rect;
    
    cellContainer.position = self.centerContainerPos;
    
    maxDisplayRect = CGRectIntersection([self getCellContainerInTableLayer:cellContainer.position],
                                        (CGRect){CGPointZero, self.contentSize});
}

- (void)addCell:(CCNode *)cell
{
    if (cell.rotation != 0)
    {
        CCLOG(@"CCTableLayer#addCell cell rotation != 0");
    }
    
    [cellContainer addChild:cell];
    
    CGPoint cellPosInContainer = [cellContainer convertToNodeSpace:[cell convertToWorldSpace:CGPointZero]];
    CGRect cellRect = {cellPosInContainer, cell.contentSize};
    
    containerRect = CGRectUnion(containerRect, cellRect);
    
    [self updateContainerRect:CGRectUnion(containerRect, cellRect)];
}

- (void)removeAllCell
{
    [cellContainer removeAllChildrenWithCleanup:YES];
    
    [self updateContainerRect:CGRectZero];
}

- (void)setScrollDirection:(CGPoint)direction
{
    scrollDirection = direction;
    
    cellContainer.position = self.centerContainerPos;
}

#pragma mark Touches
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{	
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 1;
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
    int priority = kCCMenuTouchPriority - 1;
#endif
    
	[dispatcher addTargetedDelegate:self priority: priority swallowsTouches:NO];    
}

/** Hackish stuff - stole touches from other CCTouchDispatcher targeted delegates. 
 Used to claim touch without receiving ccTouchBegan. */
- (void) claimTouch: (UITouch *) aTouch
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
#endif
    
	// Enumerate through all targeted handlers.
	for ( CCTargetedTouchHandler *handler in [dispatcher targetedHandlers] )
	{
		// Only our handler should claim the touch.
		if (handler.delegate == self)
		{
			if (![handler.claimedTouches containsObject: aTouch])
			{
				[handler.claimedTouches addObject: aTouch];
			}
		}
        else 
        {
            // Steal touch from other targeted delegates, if they claimed it.
            if ([handler.claimedTouches containsObject: aTouch])
            {
                if ([handler.delegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)])
                {
                    [handler.delegate ccTouchCancelled: aTouch withEvent: nil];
                }
                [handler.claimedTouches removeObject: aTouch];
            }
        }
	}
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event 
{
    if( scrollTouch_ == touch ) {
        scrollTouch_ = nil;
    }
}

- (void)stopMoveCellContainerWhenMaxRect:(ccTime)dt
{
    if ([cellContainer getActionByTag:TAG_MOVE_BACK] == nil)
    {
        [self unschedule:@selector(stopMoveCellContainerWhenMaxRect:)];
        return;
    }
    
    CGRect curContainerDisplayRect = [self getCellContainerInTableLayer:cellContainer.position];
    CGRect tableRect = {CGPointZero, self.contentSize};
    curContainerDisplayRect = CGRectIntersection(curContainerDisplayRect, tableRect);
    
    if (curContainerDisplayRect.size.width >= maxDisplayRect.size.width
        && curContainerDisplayRect.size.height >= maxDisplayRect.size.height)
    {
        [cellContainer stopActionByTag:TAG_MOVE_BACK];
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint((CGRect){CGPointZero, self.contentSize},
                            [self convertTouchToNodeSpace:touch]) == NO)
    {
        return NO;
    }
    
	if( scrollTouch_ == nil ) {
		scrollTouch_ = touch;
	} else {
		return NO;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	startSwipe_ = touchPoint;
    originCellContainerPos = cellContainer.position;
	state_ = kCCScrollLayerStateIdle;
    
    [cellContainer stopActionByTag:TAG_MOVE_BACK];
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch ) {
		return;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	
	// If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
	// Of course only if we not already in sliding mode
	if ( (state_ != kCCScrollLayerStateSliding) 
		&& (ccpDistance(touchPoint, startSwipe_) >= self.minimumTouchLengthToSlide) )
	{
		state_ = kCCScrollLayerStateSliding;
		
		// Avoid jerk after state change.
		startSwipe_ = touchPoint;

        [self claimTouch: touch];
	}
	
	if (state_ == kCCScrollLayerStateSliding)
	{
        CGPoint offsetPos = ccpSub(touchPoint, startSwipe_);
        if (!CGPointEqualToPoint(CGPointZero, scrollDirection))
        {
            offsetPos = ccpProject(offsetPos, scrollDirection);
        }
        
        CGPoint targetPosition = ccpAdd(originCellContainerPos, offsetPos);
        
        CGRect newRect = [self getCellContainerInTableLayer:targetPosition];
        CGRect tableRect = {CGPointZero, self.contentSize};
        
        newRect = CGRectIntersection(newRect, tableRect);

        cellContainer.position = targetPosition;
        
        if (newRect.size.width >= maxDisplayRect.size.width &&
            newRect.size.height >= maxDisplayRect.size.height)
        {
            lastContainerPosHasMaxDisplay = targetPosition;
        }
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch )
		return;
	scrollTouch_ = nil;
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    CCActionInterval *moveAction = [CCMoveTo actionWithDuration:ccpDistance(cellContainer.position, lastContainerPosHasMaxDisplay) / 400
                                                       position:lastContainerPosHasMaxDisplay];
    moveAction = [CCEaseExponentialOut actionWithAction:moveAction];
    moveAction.tag = TAG_MOVE_BACK;
    [cellContainer runAction:moveAction];
    
    [self schedule:@selector(stopMoveCellContainerWhenMaxRect:)];
}

#endif

@end
