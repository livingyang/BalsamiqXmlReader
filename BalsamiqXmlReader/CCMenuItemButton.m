//
//  CCMenuItemButton.m
//  UICreator
//
//  Created by lee living on 11-4-6.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCMenuItemButton.h"

@implementation CCMenuItemButton

@synthesize label;

- (NSString *)text
{
	if (self.label == nil)
	{
		return @"";
	}
	else
	{
		return [self.label string];
	}
}

- (void)setText:(NSString *)text
{
	if (self.label == nil)
	{
		NSLog(@"CCMenuItemButton#setText label is nil");
	}
	else
	{
		[self.label setString:text];
	}
}

- (void)initLabel:(NSString *)text 
		 fontName:(NSString *)name 
		 fontSize:(CGFloat)size
	  normalColor:(ccColor3B)normalColor
	  selectColor:(ccColor3B)selectColor
	 disableColor:(ccColor3B)disableColor
{
	if (self.label != nil)
	{
		[self removeChild:self.label cleanup:YES];
		self.label = nil;
	}
	
	self.label = [CCLabelTTF labelWithString:text fontName:name fontSize:size];
	[self addChild:self.label];
	self.label.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
	
	_labelNormalColor = normalColor;
	_labelSelectColor = selectColor;
	_labelDisableColor = disableColor;
	
	//判断标签状态
	if ([self isEnabled])
	{
		self.label.color = normalColor;
	}
	else
	{
		self.label.color = disableColor;
	}

}

////////////////////////////////////////////////////////
// 继承函数
////////////////////////////////////////////////////////

- (void)selected
{
	[super selected];
	
	if (self.label == nil)
	{
		return;
	}
	
	self.label.color = _labelSelectColor;
}

- (void)unselected
{
	[super unselected];
	
	if (self.label == nil)
	{
		return;
	}
	
	self.label.color = _labelNormalColor;
}


-(void) setIsEnabled:(BOOL)enabled
{
	[super setIsEnabled:enabled];
	
	if (self.label == nil)
	{
		return;
	}
	
	if (enabled)
	{
		self.label.color = _labelNormalColor;
	}
	else
	{
		self.label.color = _labelDisableColor;
	}
}

@end
