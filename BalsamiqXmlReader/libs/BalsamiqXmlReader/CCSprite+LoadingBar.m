//
//  CCSprite+LoadingBar.m
//  
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCSprite+LoadingBar.h"

#define TAG_LOADING_ACTION (12121)

@implementation CCSprite (LoadingBar)

- (void)loadingWithInterval:(float)interval
{
    [self stopActionByTag:TAG_LOADING_ACTION];
    
    id action = [CCSequence actions:
                 [CCRotateBy actionWithDuration:interval angle:360],
                 nil];
    
    CCRepeatForever *repeatAction = [CCRepeatForever actionWithAction:action];
    repeatAction.tag = TAG_LOADING_ACTION;
    
    [self runAction:repeatAction];
}

- (void)loadingWithInterval:(float)interval angle:(float)angle
{
    [self stopActionByTag:TAG_LOADING_ACTION];
    
    id action = [CCSequence actions:
                 [CCRotateBy actionWithDuration:0 angle:angle],
                 [CCDelayTime actionWithDuration:interval],
                 nil];
    
    CCRepeatForever *repeatAction = [CCRepeatForever actionWithAction:action];
    repeatAction.tag = TAG_LOADING_ACTION;
    
    [self runAction:repeatAction];
}

- (void)stopLoading
{
    [self stopActionByTag:TAG_LOADING_ACTION];
}

@end