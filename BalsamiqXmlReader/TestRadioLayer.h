//
//  TestRadioLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCBalsamiqLayer;
@interface TestRadioLayer : CCLayer
{

}

@property (nonatomic, assign) CCBalsamiqLayer *balsamiqLayer;

+(CCScene *) scene;

@end
