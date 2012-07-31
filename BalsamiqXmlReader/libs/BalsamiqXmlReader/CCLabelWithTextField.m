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

-(void) registerWithTouchDispatcher
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
    return CGRectContainsPoint(self.textureRect, [self convertTouchToNodeSpace:touch]);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.textField.frame = (CGRect){[self textFieldPosition], self.contentSize};
    self.textField.textAlignment = alignment_;
    self.textField.textColor = [UIColor colorWithRed:self.color.r / 255.0f
                                               green:self.color.g / 255.0f
                                                blue:self.color.b / 255.0f
                                               alpha:self.opacity / 255.0f];
    self.textField.font = [UIFont fontWithName:fontName_ size:fontSize_];
    
    self.string = @"";

    [[[CCDirector sharedDirector] openGLView] addSubview:self.textField];
    [self.textField becomeFirstResponder];
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
    [self.delegate onLabel:self textFieldShouldBeginEditing:textField];
    
    self.textField.frame = (CGRect){[self textFieldPosition], self.contentSize};
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    [textField removeFromSuperview];
    
    self.string = textField.secureTextEntry ? [self getSecrueString:self.realString] : self.realString;
    
    [self.delegate onLabel:self textFieldShouldReturn:textField];
    
    return YES;
}

@end
