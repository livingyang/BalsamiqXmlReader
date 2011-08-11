//
//  UIPaddingTextField.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-25.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPaddingTextField : UITextField
{
	float userPaddingLeft;
	float userPaddingTop;
}

- (void)setPaddingLeft:(float)paddingLeft paddingTop:(float)paddingTop;

@end
