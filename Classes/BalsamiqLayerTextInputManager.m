//
//  BalsamiqLayerTextInputManager.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-25.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "BalsamiqLayerTextInputManager.h"

@implementation BalsamiqLayerTextInputManager

+ (BalsamiqLayerTextInputManager *)instance
{
	static BalsamiqLayerTextInputManager *mgr = nil;
	if (mgr == nil)
	{
		mgr = [[BalsamiqLayerTextInputManager alloc] init];
	}
	
	return mgr;
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		textInputMgrDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[textInputMgrDic release];
	[super dealloc];
}


////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

- (void)addTextInput:(UITextField *)textInput managedBy:(id)mgr
{
	if ([textInputMgrDic objectForKey:[NSValue valueWithNonretainedObject:mgr]] == nil)
	{
		[textInputMgrDic setObject:[NSMutableSet set] forKey:[NSValue valueWithNonretainedObject:mgr]];
	}
	
	NSMutableSet *textInputSet = [textInputMgrDic objectForKey:[NSValue valueWithNonretainedObject:mgr]];
	[textInputSet addObject:textInput];
}

- (void)removeTextInputManager:(id)mgr
{
	NSMutableSet *textInputSet = [textInputMgrDic objectForKey:[NSValue valueWithNonretainedObject:mgr]];
	if (textInputSet == nil)
	{
		return;
	}
	
	for (UITextField *textInput in textInputSet)
	{
		[textInput removeFromSuperview];
	}
	
	[textInputMgrDic removeObjectForKey:[NSValue valueWithNonretainedObject:mgr]];
}

@end
