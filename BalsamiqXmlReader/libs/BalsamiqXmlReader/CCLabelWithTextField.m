//
//  CCLabelWithTextField.m
//  study_CCTextField
//
//  Created by 青宝 中 on 12-7-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCLabelWithTextField.h"

@implementation CCLabelWithTextField

@synthesize delegate;

- (UITextField *)textField
{
    if (textField_ == nil)
    {
        textField_ = [[UITextField alloc] init];
        textField_.delegate = self;
        textField_.text = self.string;
    }
    
    return textField_;
}

- (CGPoint)textFieldPosition
{
    return [[CCDirector sharedDirector] convertToUI:
            [self convertToWorldSpace:ccp(0, self.contentSize.height)]];
}

- (void)showTextFieldKeyboard
{
    [[[CCDirector sharedDirector] openGLView] addSubview:self.textField];
    [self.textField becomeFirstResponder];
    
    [[CCTouchDispatcher sharedDispatcher] setPriority:kCCMenuTouchPriority * 2 forDelegate:self];
}

- (void)hideTextFieldKeyboard
{
    [self.textField resignFirstResponder];
    [self.textField removeFromSuperview];
    
    self.string = self.textField.secureTextEntry
    ? [self getSecrueString:self.realString]
    : self.realString;
    
    [[CCTouchDispatcher sharedDispatcher] setPriority:kCCMenuTouchPriority forDelegate:self];
}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:kCCMenuTouchPriority
                                              swallowsTouches:YES];
}

- (void)dealloc
{
    if (textField_.superview != nil)
    {
        [textField_ removeFromSuperview];
    }
    [textField_ release];
    [super dealloc];
}

- (void)onEnter
{
    [self registerWithTouchDispatcher];
    
    [super onEnter];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return (CGRectContainsPoint(self.textureRect, [self convertTouchToNodeSpace:touch])
            || self.textField.isFirstResponder);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.textField.isFirstResponder)
    {
        [self hideTextFieldKeyboard];
        return;
    }
    
    self.textField.frame = (CGRect){[self textFieldPosition], self.contentSize};
    self.textField.textAlignment = alignment_;
    self.textField.textColor = [UIColor colorWithRed:self.color.r / 255.0f
                                               green:self.color.g / 255.0f
                                                blue:self.color.b / 255.0f
                                               alpha:self.opacity / 255.0f];
    self.textField.font = [UIFont fontWithName:fontName_ size:fontSize_];
    
    self.string = @"";
    
    [self showTextFieldKeyboard];
}

- (NSString *)realString
{
    return (self.textField.text.length == 0) ? self.textField.placeholder : self.textField.text;
}

- (NSString *)getSecrueString:(NSString *)string
{
    NSMutableString *text = [NSMutableString string];
    for (int i = 0; i < string.length; ++i)
    {
        [text appendString:@"●"];
    }
    
    return text;
}

- (void)setSecureEntry:(BOOL)isEnable
{
    self.textField.secureTextEntry = isEnable;
    self.string = isEnable ? [self getSecrueString:self.realString] : self.realString;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(onLabel:textFieldShouldBeginEditing:)])
    {
        [self.delegate onLabel:self textFieldShouldBeginEditing:textField];
    }
    
    self.textField.frame = (CGRect){[self textFieldPosition], self.contentSize};
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(onLabel:textFieldDidEndEditing:)])
    {
        [self.delegate onLabel:self textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(onLabel:textFieldShouldReturn:)])
    {
        [self.delegate onLabel:self textFieldShouldReturn:textField];
    }
    
    [self hideTextFieldKeyboard];
    
    return YES;
}

@end
