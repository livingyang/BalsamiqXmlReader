//
//  BalsamiqLayerTextInputManager.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-25.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BalsamiqLayerTextInputManager : NSObject
{
	NSMutableDictionary *textInputMgrDic;
}

+ (BalsamiqLayerTextInputManager *)instance;

- (void)addTextInput:(UITextField *)textInput managedBy:(id)mgr;
- (void)removeTextInputManager:(id)mgr;

@end
