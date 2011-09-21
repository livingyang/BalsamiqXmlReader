//
//  BalsamiqControlData.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BalsamiqControlData : NSObject
{
	NSMutableDictionary *attributeDic;
	
	NSMutableDictionary *propertyDic;
}

@property (nonatomic, retain) NSMutableDictionary *attributeDic;
@property (nonatomic, retain) NSMutableDictionary *propertyDic;

@end
