//
//  CCLoadingBar.m
//  study_LoadingBar
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCLoadingBar.h"

//#define LOADING_BAR_PIC @"loading-bar.png"
//
//#define BAR_LEAF_COUNT (12)

@implementation CCLoadingBar

- (void)updateBar:(ccTime)dt
{
	elaspeTime += dt;
	
	int curBarLeaf = fmod(elaspeTime, barDisplayCycle) / barDisplayCycle * barLeafCount;
	self.rotation = 360 / barLeafCount * curBarLeaf;
}

- (void)setBarDisplayCycle:(float)displayCycle barLeafCount:(int)leafCount
{
	NSAssert(displayCycle > 0 && leafCount > 0,
			 @"CCLoadingBar#setBarDisplayCycle param error");
	
	barDisplayCycle = displayCycle;
	barLeafCount = leafCount;
}

- (void)setBarSize:(float)size
{
	self.scaleX = size / self.contentSize.width;
	self.scaleY = size / self.contentSize.height;
}

- (void)onEnter
{
	[self schedule:@selector(updateBar:)];
	[super onEnter];
}

- (void)onExit
{
	[self unschedule:@selector(updateBar:)];
	[super onExit];
}

@end
