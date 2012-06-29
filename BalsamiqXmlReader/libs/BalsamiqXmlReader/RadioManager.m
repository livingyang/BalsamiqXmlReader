//
//  CheckBoxManager.m
//  FatBirdsBoardGames
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "RadioManager.h"
#import "CCBalsamiqLayer.h"

@implementation RadioManager

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		infoAndItemDic = [[NSMutableDictionary alloc] init];
        itemNameAndTabDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[infoAndItemDic release];
    [itemNameAndTabDic release];
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
    
    [self updateSelectTab];
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

- (void)updateSelectTab
{
    NSString *selectTabName = self.selectedItemInfo;
    
    for (NSString *tabName in [itemNameAndTabDic allKeys])
    {
        CCNode *tab = [itemNameAndTabDic objectForKey:tabName];
        [tab removeFromParentAndCleanup:NO];
        
        if ([selectTabName isEqualToString:tabName])
        {
            [tabParent addChild:tab];
        }
    }
}

- (void)setItemName:(NSString *)itemName withTab:(CCNode *)tab
{
    if ([itemNameAndTabDic objectForKey:itemName] != nil)
    {
        CCLOG(@"RadioManager#setItemName duplicate tab = %@", itemName);
        return;
    }
    
    [itemNameAndTabDic setObject:tab forKey:itemName];
    if (tab.parent != nil)
    {
        if (tabParent == nil)
        {
            tabParent = tab.parent;
        }
        else
        {
            if (tabParent != tab.parent)
            {
                CCLOG(@"RadioManager#setItemName error layerParent != node.parent");
            }
        }
        
        [tab removeFromParentAndCleanup:NO];
    }
}

@end
