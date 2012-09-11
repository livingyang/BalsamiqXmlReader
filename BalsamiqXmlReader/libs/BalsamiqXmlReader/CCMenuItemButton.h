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

@property (nonatomic, assign) NSString *text;
@property (nonatomic, assign) CCLabelTTF *label;

@property ccColor3B labelNormalColor;
@property ccColor3B labelSelectColor;
@property ccColor3B labelDisableColor;

- (void)initLabel:(NSString *)text 
		 fontName:(NSString *)name 
		 fontSize:(CGFloat)size
	  normalColor:(ccColor3B)normalColor
	  selectColor:(ccColor3B)selectColor 
	 disableColor:(ccColor3B)disableColor;

@end
