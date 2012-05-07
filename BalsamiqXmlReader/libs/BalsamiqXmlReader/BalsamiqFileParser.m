//
//  BalsamiqFileParser.m
//  ReplaceKissXml
//
//  Created by apple on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BalsamiqFileParser.h"
#import "BalsamiqControlData.h"

@implementation BalsamiqFileParser

+ (BalsamiqFileParser *)instance
{
    static BalsamiqFileParser *parser = nil;
    if (parser == nil)
    {
        parser = [[BalsamiqFileParser alloc] init];
    }
    
    return parser;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"control"])
    {
        NSAssert(curParseData == nil, @"curParseData != nil, xml node control has subnode control");
        
        curParseData = [[[BalsamiqControlData alloc] init] autorelease];
        [curParseData.attributeDic setDictionary:attributeDict];
        
        [curParseArray addObject:curParseData];
    }
    else if ([elementName isEqualToString:@"controlProperties"])
    {
        isParsingProperties = YES;
        curParseElementName = nil;
    }
    else
    {
        curParseElementName = elementName;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"control"])
    {
        curParseData = nil;
    }
    else if ([elementName isEqualToString:@"controlProperties"])
    {
        isParsingProperties = NO;
    }
    else
    {
        curParseElementName = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (curParseElementName != nil && isParsingProperties)
    {
        [curParseData.propertyDic setValue:string forKey:curParseElementName];
    }
}

- (NSMutableArray *)getControlsDataByData:(NSData *)balsamiqData
{
    if (balsamiqData == nil)
    {
        return nil;
    }
    
    curParseArray = [NSMutableArray array];
    isParsingProperties = NO;
    
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:balsamiqData] autorelease];
    parser.delegate = self;
    [parser parse];
    
    return curParseArray;
}

- (NSMutableArray *)getControlsData:(NSString *)filePath
{
    return [self getControlsDataByData:[NSData dataWithContentsOfFile:filePath]];
}

@end
