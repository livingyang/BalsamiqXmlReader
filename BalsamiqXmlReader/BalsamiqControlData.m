//
//  BalsamiqControlData.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "BalsamiqControlData.h"
#import "DDXML.h"

@implementation BalsamiqControlData

@synthesize attributeDic;
@synthesize propertyDic;

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

- (NSString *)description
{
	return [NSString stringWithFormat:@"<attributes = %@,\n properties = %@>", self.attributeDic, self.propertyDic];
}

- (void) dealloc
{
	self.attributeDic = nil;
	self.propertyDic = nil;
	
	[super dealloc];
}

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

+ (NSMutableArray *)parseData:(NSString *)balsamiqStr
{
	if (balsamiqStr == nil || [balsamiqStr isEqualToString:@""])
	{
		NSLog(@"BalsamiqControlData#parseData data is invalid");
		return nil;
	}
	
	DDXMLDocument *ddDoc = [[[DDXMLDocument alloc] initWithXMLString:balsamiqStr
															 options:0 
															   error:nil] autorelease];
	
	NSArray *controls = [ddDoc nodesForXPath:@"//control" error:nil];
	
	NSMutableArray *controlsData = [NSMutableArray arrayWithCapacity:controls.count];
	
	for (DDXMLElement *element in controls)
	{
		BalsamiqControlData *controlData = [[[BalsamiqControlData alloc] init] autorelease];
		controlData.attributeDic = [NSMutableDictionary dictionary];
		controlData.propertyDic = [NSMutableDictionary dictionary];
		
		[controlsData addObject:controlData];
		
		// 1解析属性
		for (DDXMLNode *node in [element attributes])
		{
			[controlData.attributeDic setObject:[node stringValue] forKey:[node name]];
		}
		
		// 2解析属性节点
		NSArray *propertys = [element nodesForXPath:@"controlProperties/*" error:nil];
		
		for (DDXMLNode *node in propertys)
		{
			[controlData.propertyDic setObject:[node stringValue] forKey:[node name]];
		}
	}
	
	return controlsData;
}

@end
