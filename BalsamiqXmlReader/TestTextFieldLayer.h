//
//  TestTextFieldLayer.h
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-7-31.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelWithTextField.h"

@class CCBalsamiqLayer;
@interface TestTextFieldLayer : CCLayer <CCLabelWithTextFieldDelegate>
{
    CCBalsamiqLayer *balsamiqLayer;
}

+(CCScene *) scene;

@end
