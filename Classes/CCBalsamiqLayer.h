//
//  CCBalsamiqLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "BalsamiqXmlDef.h"

@interface CCBalsamiqLayer : CCLayer

- (id)initWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle;

+ (id)layerWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle;

@end

// #1 CCBalsamiqLayer所创建的UITextField，会在内部进行释放，无须外部释放