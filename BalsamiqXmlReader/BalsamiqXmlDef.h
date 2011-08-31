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

#define KEY_BALSAMIQ_ROOT_DIR @"RootDir"
#define KEY_BALSAMIQ_FONT_NAME @"FontName"
#define KEY_BALSAMIQ_BTN_NORMAL_TEXT_COLOR @"ButtonNormalTextColor"
#define KEY_BALSAMIQ_BTN_SELECT_TEXT_COLOR @"ButtonSelectTextColor"
#define KEY_BALSAMIQ_INPUT_TEXT_COLOR @"TextInputColor"

extern NSString *balsamiqFontName;
extern ccColor3B buttonNormalTextColor;
extern ccColor3B buttonSelectTextColor;
extern ccColor3B textInputColor;

@class CCMenuItemButton;
@class CCLoadingBar;
@protocol BalsamiqReaderDelegate

@optional
- (void)onButtonCreated:(CCMenuItemButton *)button name:(NSString *)name;

@optional
- (void)onImageCreated:(CCSprite *)image name:(NSString *)name;

@optional
- (void)onLabelCreated:(CCLabelTTF *)label name:(NSString *)name;

@optional
- (void)onTextInputCreated:(UITextField *)textInput name:(NSString *)name;

@optional
- (void)onWebViewCreated:(UIWebView *)webView name:(NSString *)name;

@optional
- (void)onRadioItemSelected:(CCMenuItemImage *)item withInfo:(NSString *)info;

@optional
- (void)onLoadingBarCreated:(CCLoadingBar *)loadingBar name:(NSString *)name;

@end

#endif //BALSAMIQXMLDEF_H