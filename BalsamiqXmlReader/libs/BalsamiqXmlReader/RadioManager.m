//
//  CheckBoxManager.m
//  FatBirdsBoardGames
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "RadioManager.h"
#import "cocos2d.h"
#import "BalsamiqXmlDef.h"

@implementation RadioManager

@synthesize delegate;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		infoAndItemDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[infoAndItemDic release];
	[super dealloc];
}

- (void)addItem:(CCMenuItemImage *)item withInfo:(NSString *)info
{
	[infoAndItemDic setValue:item forKey:info];
}

- (void)selectItem:(CCMenuItemImage *)item
{
	if ([self isSubitem:item] == NO)
	{
		return;
	}
	
	for (NSString *infoKey in [infoAndItemDic allKeys])
	{
		CCMenuItemImage *value = [infoAndItemDic valueForKey:infoKey];
		
		if (value == item)
		{
			[value selected];
			
			if ([self.delegate respondsToSelector:@selector(onRadioItemSelected:withInfo:)])
			{
				[self.delegate onRadioItemSelected:value withInfo:infoKey];
			}
		}
		else
		{
			[value unselected];
		}
	}
}

- (BOOL)isSubitem:(CCMenuItemImage *)item
{
	return [[infoAndItemDic allValues] containsObject:item];
}

- (void)selectFirstItem
{
	if (infoAndItemDic.count > 0)
	{
		NSArray *inOrderItemArray = [[infoAndItemDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
		
		[self selectItem:[infoAndItemDic objectForKey:[inOrderItemArray objectAtIndex:0]]];
	}
}

@end
