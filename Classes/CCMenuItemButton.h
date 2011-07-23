//
//  CCMenuItemButton.h
//  UICreator
//
//  Created by lee living on 11-4-6.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//加入标签的显示
@interface CCMenuItemButton : CCMenuItemImage 
{
	CCLabelTTF *_label;
	
	ccColor3B _labelNormalColor;
	ccColor3B _labelSelectColor;
	ccColor3B _labelDisableColor;
}

@property (nonatomic, assign) NSString *text;
@property (nonatomic, assign) CCLabelTTF *label;

- (void)initLabel:(NSString *)text 
		 fontName:(NSString *)name 
		 fontSize:(CGFloat)size
	  normalColor:(ccColor3B)normalColor
	  selectColor:(ccColor3B)selectColor 
	 disableColor:(ccColor3B)disableColor;

@end
