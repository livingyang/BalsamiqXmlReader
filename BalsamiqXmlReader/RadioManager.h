//
//  CheckBoxManager.h
//  FatBirdsBoardGames
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCMenuItemImage;

@interface RadioManager : NSObject
{
	NSMutableDictionary *infoAndItemDic;
}

@property (nonatomic, assign) id /*<BalsamiqReaderDelegate>*/ delegate;

- (void)addItem:(CCMenuItemImage *)item withInfo:(NSString *)info;

- (void)selectItem:(CCMenuItemImage *)item;

- (BOOL)isSubitem:(CCMenuItemImage *)item;

- (void)selectFirstItem;

@end
