//
//  CCSprite+LoadingBar.h
//  
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCSprite (LoadingBar)

- (void)loadingWithInterval:(float)interval;

- (void)loadingWithInterval:(float)interval angle:(float)angle;

- (void)stopLoading;

@end
