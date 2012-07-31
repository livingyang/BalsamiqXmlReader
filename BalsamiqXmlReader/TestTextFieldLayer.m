//
//  TestTextFieldLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-7-31.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestTextFieldLayer.h"
#import "TestButtonLayer.h"
#import "TestAlertLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestTextFieldLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[TestTextFieldLayer node]];
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestButtonLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestAlertLayer scene]]];
}

-(id) init
{
	if( (self=[super init]))
	{
        balsamiqLayer = [CCBalsamiqLayer layerWithBalsamiqFile:@"1.3-test-textfield.bmml"
                                                   eventHandle:self];
		[self addChild:balsamiqLayer];
        
        CCLabelWithTextField *textField = [balsamiqLayer getControlByName:@"bottom"];
        textField.delegate = self;
        
        CCLabelWithTextField *passwordTextField = [balsamiqLayer getControlByName:@"password"];
        [passwordTextField setSecureEntry:YES];
        passwordTextField.delegate = self;
	}
	return self;
}

#pragma mark -
#pragma mark CCLabelWithTextFieldDelegate

const CGPoint EditOffsetPos = {0, 120};

- (void)onLabel:(CCLabelWithTextField *)label textFieldShouldBeginEditing:(UITextField *)textField
{
    if (label == [balsamiqLayer getControlByName:@"bottom"])
    {
        self.position = ccpAdd(self.position, EditOffsetPos);
    }
}

- (void)onLabel:(CCLabelWithTextField *)label textFieldShouldReturn:(UITextField *)textField
{
    if (label == [balsamiqLayer getControlByName:@"bottom"])
    {
        self.position = ccpSub(self.position, EditOffsetPos);
    }
    else if (label == [balsamiqLayer getControlByName:@"password"])
    {
        NSLog(@"password = %@", label.realString);
    }
}

@end
