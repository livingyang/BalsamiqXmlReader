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
        itemNameAndSelectLayerDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[infoAndItemDic release];
    [itemNameAndSelectLayerDic release];
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
    
    [self updateSelectLayer];
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

- (void)updateLayerParent
{
    layerParent = nil;
    
    for (CCLayer *layer in [itemNameAndSelectLayerDic allValues])
    {
        if (layer.parent != nil)
        {
            if (layerParent == nil)
            {
                layerParent = layer.parent;
                [layer removeFromParentAndCleanup:NO];
            }
            else
            {
                if (layerParent != layer.parent)
                {
                    CCLOG(@"RadioManager#updateLayerParent error layerParent != layer.parent");
                }
                
                [layer removeFromParentAndCleanup:NO];
            }
        }
    }
    
    if (layerParent == nil)
    {
        CCLOG(@"RadioManager#updateLayerParent error layerParent == nil");
    }
}

- (void)updateSelectLayer
{
    NSString *selectName = self.selectedItemInfo;
    
    for (NSString *itemName in [itemNameAndSelectLayerDic allKeys])
    {
        CCLayer *layer = [itemNameAndSelectLayerDic objectForKey:itemName];
        
        if ([selectName isEqualToString:itemName])
        {
            [layerParent addChild:layer];
        }
        else
        {
            [layer removeFromParentAndCleanup:NO];
        }
    }
}

- (void)setItemAndSelectLayer:(NSDictionary *)itemAndSelectLayerDic
{
    [itemNameAndSelectLayerDic removeAllObjects];
    [itemNameAndSelectLayerDic addEntriesFromDictionary:itemAndSelectLayerDic];
    
    for (NSString *itemName in [itemNameAndSelectLayerDic allKeys])
    {
        if ([infoAndItemDic objectForKey:itemName] == nil)
        {
            CCLOG(@"RadioManager#setItemAndSelectLayer: %@ is invalid item", itemName);
        }
    }
    
    [self updateLayerParent];
    [self updateSelectLayer];
}

@end
