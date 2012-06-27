//
//  CheckBoxManager.h
//  FatBirdsBoardGames
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCMenuItemImage;
@class CCLayer;
@interface RadioManager : NSObject
{
	NSMutableDictionary *infoAndItemDic;
    
    id layerParent;
    NSMutableDictionary *itemNameAndSelectLayerDic;
}

@property (nonatomic, readonly) NSString *selectedItemInfo;

- (void)addItem:(CCMenuItemImage *)item withInfo:(NSString *)info;

- (void)selectItem:(CCMenuItemImage *)item;

- (void)selectItemByName:(NSString *)itemName;

- (BOOL)isSubitem:(CCMenuItemImage *)item;

- (void)setItemAndSelectLayer:(NSDictionary *)itemAndSelectLayerDic;

@end
