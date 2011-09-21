//
//  BalsamiqFileParser.h
//  ReplaceKissXml
//
//  Created by apple on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BalsamiqControlData;
@interface BalsamiqFileParser : NSObject <NSXMLParserDelegate>
{
    BalsamiqControlData *curParseData;
    NSString *curParseElementName;
    BOOL isParsingProperties;
    
    NSMutableArray *curParseArray;
}

+ (BalsamiqFileParser *)instance;

- (NSMutableArray *)getControlsDataByData:(NSData *)balsamiqData;

- (NSMutableArray *)getControlsData:(NSString *)filePath;

@end
