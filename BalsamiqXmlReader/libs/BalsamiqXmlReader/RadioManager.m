//
//  CheckBoxManager.m
//  FatBirdsBoardGames
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "RadioManager.h"
#import "cocos2d.h"
#import "CCBalsamiqLayer.h"

@implementation RadioManager

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
		}
		else
		{
			[value unselected];
		}
	}
}

- (void)selectItemByName:(NSString *)itemName
{
    [self selectItem:[infoAndItemDic valueForKey:itemName]];
}

- (BOOL)isSubitem:(CCMenuItemImage *)item
{
	return [[infoAndItemDic allValues] containsObject:item];
}

- (NSString *)selectedItemInfo
{
    for (NSString *infoKey in [infoAndItemDic allKeys])
	{
		CCMenuItemImage *value = [infoAndItemDic valueForKey:infoKey];
        if (value.isSelected)
        {
            return infoKey;
        }
    }
    
    return nil;
}

@end
