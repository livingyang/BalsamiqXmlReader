//
//  BalsamiqControlData.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "BalsamiqControlData.h"

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

- (id)init
{
    self = [super init];
    if (self)
    {
        self.attributeDic = [NSMutableDictionary dictionary];
        self.propertyDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void) dealloc
{
	self.attributeDic = nil;
	self.propertyDic = nil;
	
	[super dealloc];
}

@end
