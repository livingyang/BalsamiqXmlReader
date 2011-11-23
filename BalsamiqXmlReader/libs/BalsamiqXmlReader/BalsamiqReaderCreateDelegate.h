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

@class CCMenuItemButton;
@class CCLoadingBar;
@protocol BalsamiqReaderCreateDelegate

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