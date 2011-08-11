//
//  UIPaddingTextField.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-25.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "UIPaddingTextField.h"


@implementation UIPaddingTextField

- (void)setPaddingLeft:(float)paddingLeft
			paddingTop:(float)paddingTop
{
	userPaddingLeft = paddingLeft;
	userPaddingTop = paddingTop;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
	return CGRectMake(bounds.origin.x + userPaddingLeft, bounds.origin.y + userPaddingTop,
					  bounds.size.width - userPaddingLeft, bounds.size.height - userPaddingTop);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return [self textRectForBounds:bounds];
}

@end
