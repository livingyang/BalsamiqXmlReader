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

@synthesize cellContainer;

@synthesize minimumTouchLengthToSlide;
@synthesize isDebug;

@synthesize vectorMove;
@synthesize maxDistance;

- (id)init
{
    self = [super init];
	if (self != nil)
    {
        self.isTouchEnabled = YES;
		self.isRelativeAnchorPoint = YES;
        
        cellContainer = [CCNode node];
        [self addChild:cellContainer];
        
        self.vectorMove = CGPointZero;
        maxDistance = 0;
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
    
    CGRect visitRect =
    {
        [self convertToWorldSpace:CGPointZero],
        self.contentSize,
    };
    visitRect = CC_RECT_POINTS_TO_PIXELS(visitRect);
    glScissor(visitRect.origin.x, visitRect.origin.y, visitRect.size.width, visitRect.size.height);
    
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

- (void)draw
{
    if (isDebug)
    {
        glLineWidth(3);
        
        glColor4ub(0, 0, 100, 200);
        ccDrawSolidRect(CGPointZero, ccpFromSize(self.contentSize));
    }
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
    startTouchCellContainerPos = cellContainer.position;
	state_ = kCCScrollLayerStateIdle;
    
    [cellContainer stopActionByTag:TAG_MOVE_BACK];
    
    vectorInertia = CGPointZero;
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
        
        lastTouchTimeStamp = touch.timestamp;
	}
	
	if (state_ == kCCScrollLayerStateSliding)
	{
        CGPoint offsetPos = ccpSub(touchPoint, startSwipe_);
        
        if (!CGPointEqualToPoint(CGPointZero, self.vectorMove))
        {
            offsetPos = ccpProject(offsetPos, self.vectorMove);
        }
        
        CGPoint targetPosition = ccpAdd(startTouchCellContainerPos, offsetPos);
        cellContainer.position = targetPosition;
        
        [self updateInertia];
	}
}

#pragma mark -
#pragma mark move distance manage

- (CGPoint)getPositionFromDistance:(float)distance
{
    if (CGPointEqualToPoint(self.vectorMove, CGPointZero))
    {
        return originCellContainerPos;
    }
    
    return ccpAdd(originCellContainerPos, ccpMult(ccpNormalize(self.vectorMove), distance));
}

- (float)getDistanceFromPosition:(CGPoint)pos
{
    return ccpDot(ccpNormalize(self.vectorMove), ccpSub(pos, originCellContainerPos));
}

- (float)curDistance
{
    return [self getDistanceFromPosition:cellContainer.position];
}

- (void)setCurDistance:(float)curDistance
{
    [cellContainer stopActionByTag:TAG_MOVE_BACK];
    cellContainer.position = [self getPositionFromDistance:clampf(curDistance, 0, self.maxDistance)];
}

#pragma mark -
#pragma mark inertia manager

- (CGPoint)getInertiaPos
{
    return ccp(vectorInertia.x * fabsf(vectorInertia.x),
               -vectorInertia.y * fabsf(vectorInertia.y));
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch )
		return;
	scrollTouch_ = nil;
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    [self updateInertia];
    
    float curDistance = 0;
    float targetDistance = 0;
    float moveBackDistance = 0;
    
    if (!CGPointEqualToPoint(self.vectorMove, CGPointZero) && maxDistance > 0)
    {
        curDistance = self.curDistance;
        
        targetDistance = [self getDistanceFromPosition:ccpAdd(cellContainer.position, [self getInertiaPos])];
        
        targetDistance = clampf(targetDistance, -100, maxDistance + 100);
        
        moveBackDistance = clampf(targetDistance, 0, maxDistance);
    }
    
    CGPoint targetPos = [self getPositionFromDistance:targetDistance];
    CGPoint moveBackPos = [self getPositionFromDistance:moveBackDistance];
    
    id moveToTargetAction = [CCEaseExponentialOut actionWithAction:
                             [CCMoveTo actionWithDuration:fabsf(targetDistance - curDistance) / 400 position:targetPos]];
    id moveBackAction = [CCEaseExponentialOut actionWithAction:
                         [CCMoveTo actionWithDuration:fabsf(targetDistance - moveBackDistance) / 400 position:moveBackPos]];
    CCSequence *action = [CCSequence actions:moveToTargetAction, moveBackAction, nil];
    action.tag = TAG_MOVE_BACK;
    
    [cellContainer runAction:action];
}

#endif

- (void)updateInertia
{
    float increaseRate = scrollTouch_.timestamp - lastTouchTimeStamp;
    lastTouchTimeStamp = scrollTouch_.timestamp;
    increaseRate = clampf(1 - increaseRate, 0, 1);
    
    CGPoint increaseInertia = ccpMult(vectorInertia, increaseRate);
    
    CGPoint offsetTouchMove = ccpSub([scrollTouch_ locationInView:scrollTouch_.view],
                                     [scrollTouch_ previousLocationInView:scrollTouch_.view]);
    
    vectorInertia = ccpMidpoint(increaseInertia, offsetTouchMove);
}

- (CGRect)getCellContainerRect:(CCNode *)container
{
    CGRect nodeContainRect = CGRectZero;
    for (CCNode *node in container.children)
    {
        CGPoint nodePoint = [container convertToNodeSpace:[node convertToWorldSpace:CGPointZero]];
        CGRect nodeRect = {nodePoint, node.contentSize};
        
        nodeContainRect = CGRectEqualToRect(CGRectZero, nodeContainRect)
        ? nodeRect
        : CGRectUnion(nodeContainRect, nodeRect);
    }
    
    return nodeContainRect;
}

- (void)setCellContainer:(CCNode *)container
{    
    [self removeChild:cellContainer cleanup:YES];
    cellContainer = container;
    [self addChild:cellContainer];
    
    originCellContainerPos = cellContainer.position;
}

- (CGPoint)getPosFromRect:(CGRect)rect withDirection:(CGPoint)direction
{
    CGPoint offsetDirection = ccpAdd(ccp(1, 1), ccpNormalize(direction));
    return ccpAdd(rect.origin, ccpCompMult(offsetDirection, ccp(rect.size.width / 2, rect.size.height / 2)));
}

- (void)setCellContainer:(CCNode *)container autoSetWithVectorMove:(CGPoint)vecMove
{
    self.vectorMove = vecMove;
    
    CGRect nodeContainRect = [self getCellContainerRect:container];
    self.maxDistance = [self getMaxDistanceFromContainer:container];
    
    CGPoint cellAttachPos = [self getPosFromRect:nodeContainRect withDirection:vecMove];
    CGPoint tableAttachPos = [self getPosFromRect:(CGRect){CGPointZero, self.contentSize} withDirection:vecMove];
    
    container.position = ccpSub(tableAttachPos, cellAttachPos);
    
    [self setCellContainer:container];
}

- (float)getMaxDistanceFromContainer:(CCNode *)container
{
    CGRect nodeContainRect = [self getCellContainerRect:container];
    
    CGPoint subSize = ccpSub(ccpFromSize(nodeContainRect.size), ccpFromSize(self.contentSize));
    subSize.x = subSize.x > 0 ? subSize.x : 0;
    subSize.y = subSize.y > 0 ? subSize.y : 0;
    
    return ccpLength(ccpProject(subSize, self.vectorMove));
}

- (void)resetMaxDistance
{
    self.maxDistance = [self getMaxDistanceFromContainer:cellContainer];
}

- (float)getCellDistance:(CCNode *)cell
{
    while (cell != nil)
    {
        if (cell.parent == cellContainer)
        {
            CGPoint tableCenterPos = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
            tableCenterPos = [cellContainer convertToNodeSpace:[self convertToWorldSpace:tableCenterPos]];
            
            return [self getDistanceFromPosition:ccpAdd(ccpSub(tableCenterPos, cell.position), cellContainer.position)];
        }
        cell = cell.parent;
    }
    
    return self.curDistance;
}

@end
