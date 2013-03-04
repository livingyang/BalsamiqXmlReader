//
//  TestScrollLayer.h
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCTableLayer.h"

@interface TestScrollLayer : CCLayer <CCTableLayerDelegate>
{
}

@property (nonatomic, assign) CCTableLayer *tableVLayer;
@property (nonatomic, assign) CCTableLayer *tableHLayer;

+(CCScene *) scene;
@end
