//
//  CCLoadingBar.h
//  study_LoadingBar
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLoadingBar : CCSprite
{
	float barDisplayCycle;
	
	float elaspeTime;
	
	int barLeafCount;
}

- (void)setBarDisplayCycle:(float)displayCycle barLeafCount:(int)leafCount;

- (void)setBarSize:(float)size;

@end
