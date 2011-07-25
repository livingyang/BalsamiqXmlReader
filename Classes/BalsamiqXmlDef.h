//
//  BalsamiqXmlDef.h
//  CutTheChain
//
//  Created by lee living on 11-6-24.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#ifndef BALSAMIQXMLDEF_H
#define BALSAMIQXMLDEF_H

#import <Foundation/Foundation.h>
#import "cocos2d.h"

extern NSString *balsamiqFontName;
extern ccColor3B buttonNormalTextColor;
extern ccColor3B buttonSelectTextColor;
extern ccColor3B textInputColor;

@class CCMenuItemButton;
@protocol BalsamiqReaderDelegate

@optional
- (void)onButtonCreated:(CCMenuItemButton *)button name:(NSString *)name;

@optional
- (void)onImageCreated:(CCSprite *)image name:(NSString *)name;

@optional
- (void)onLabelCreated:(CCLabelTTF *)label name:(NSString *)name;

@end

#endif //BALSAMIQXMLDEF_H