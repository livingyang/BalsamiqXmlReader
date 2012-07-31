//
//  CCLabelWithTextField.h
//  study_CCTextField
//
//  Created by 青宝 中 on 12-7-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCLabelWithTextField;
@protocol CCLabelWithTextFieldDelegate <NSObject>

- (void)onLabel:(CCLabelWithTextField *)label textFieldShouldBeginEditing:(UITextField *)textField;
- (void)onLabel:(CCLabelWithTextField *)label textFieldShouldReturn:(UITextField *)textField;

@end

@interface CCLabelWithTextField : CCLabelTTF <CCTargetedTouchDelegate, UITextFieldDelegate>
{
    UITextField *textField_;
}

@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, assign) id<CCLabelWithTextFieldDelegate> delegate;              // CCLabelWithTextFieldDelegate

- (NSString *)realString;
- (void)setSecureEntry:(BOOL)isEnable;

@end
