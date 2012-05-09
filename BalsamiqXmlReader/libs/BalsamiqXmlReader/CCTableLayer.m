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
#endif

@interface CCTableLayer (Private)

- (void)updateTotalCellVisible;

@end


@implementation CCTableLayer

@synthesize scrollDirection;
@synthesize minimumTouchLengthToSlide;
@synthesize isDebug;

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    tableAreaDebug.contentSize = contentSize;
}

- (id)init
{
    self = [super init];
	if (self != nil)
    {
        self.isTouchEnabled = YES;
		self.isRelativeAnchorPoint = YES;
        
        containerRect = CGRectZero;
        scrollDirection = CGPointZero;
        
        tableAreaDebug = [CCLayerColor layerWithColor:ccc4(100, 0, 0, 100)
                                                width:self.contentSize.width
                                               height:self.contentSize.height];
        [self addChild:tableAreaDebug];
        tableAreaDebug.visible = NO;
        
        cellContainer = [CCNode node];
        [self addChild:cellContainer];
        
        containerAreaLayer = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 100)];
        containerAreaLayer.contentSize = CGSizeMake(100, 100);
        [cellContainer addChild:containerAreaLayer];
        containerAreaLayer.visible = NO;
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
    
    glScissor(x, y, self.contentSize.width, self.contentSize.height);   
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

- (void)setIsDebug:(BOOL)debug
{
    isDebug = debug;
    
    containerAreaLayer.visible = debug;
    tableAreaDebug.visible = debug;
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
    
    containerAreaLayer.position = containerRect.origin;
    containerAreaLayer.contentSize = containerRect.size;
    
    cellContainer.position = self.centerContainerPos;
    
    [self updateTotalCellVisible];
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
    
    [self updateContainerRect:CGRectUnion(containerRect, cellRect)];
}

- (void)removeAllCell
{
    for (int i = cellContainer.children.count - 1; i >= 0; --i)
    {
        CCNode *cell = [cellContainer.children objectAtIndex:i];
        
        if (cell != containerAreaLayer)
        {
            [cellContainer removeChild:cell cleanup:YES];
        }
    }
    
    [self updateContainerRect:CGRectZero];
}

- (void)updateTotalCellVisible
{
    for (CCNode *cell in cellContainer.children)
    {
        if (cell == containerAreaLayer)
        {
            continue;
        }
        
        CGRect cellRectAtTable = {[self convertToNodeSpace:[cell convertToWorldSpace:CGPointZero]], cell.contentSize};
        
        if (CGRectIntersectsRect(cellRectAtTable, (CGRect){CGPointZero, self.contentSize}))
        {
            cell.visible = YES;
        }
        else
        {
            cell.visible = NO;
        }
    }
}

- (void)setScrollDirection:(CGPoint)direction
{
    scrollDirection = direction;
    
    cellContainer.position = self.centerContainerPos;
    
    [self updateTotalCellVisible];
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
    originCellContainerPos = cellContainer.position;
	state_ = kCCScrollLayerStateIdle;
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
        
        cellContainer.position = ccpAdd(originCellContainerPos, offsetPos);
        [self updateTotalCellVisible];
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch )
		return;
	scrollTouch_ = nil;
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
}

#endif

@end
