//
//  TestLoadingBarLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-31.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCBalsamiqLayer;
@interface TestLoadingBarLayer : CCLayer
{
    CCBalsamiqLayer *layer;
}

+(CCScene *) scene;

@end
