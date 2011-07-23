//
//  CCLayer+BalsamiqParser.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "BalsamiqXmlDef.h"

@interface CCLayer(BalsamiqParser)

- (id)initWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle;

+ (id)layerWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle;

@end
