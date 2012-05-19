//
//  HelloWorldLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright LieHuo Tech 2011. All rights reserved.
//


// Import the interfaces
#import "MainLayer.h"

#import "BalsamiqControlData.h"
#import "CCBalsamiqLayer.h"
#import "CCBalsamiqScene.h"
#import "CCAlertLayer.h"

#import "TestAlertLayer.h"
#import "BalsamiqReaderConfig.h"

@implementation MainLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCBalsamiqScene node];
	
	// add layer as a child to scene
	[scene addChild:[MainLayer node]];
	
	// return the scene
	return scene;
}


#pragma mark - 
#pragma mark UITextFieldDelegate

const CGPoint EditOffset = {0, 160};

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    
    self.position = ccpAdd(self.position, EditOffset);
    textField.center = ccpSub(textField.center, EditOffset);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing text = %@", textField.text);
    
    self.position = ccpSub(self.position, EditOffset);
    textField.center = ccpAdd(textField.center, EditOffset);
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestAlertLayer scene]]];
}

- (void)onDisableClick:(id)sender
{}

- (void)onClick_toggle_ok:(CCMenuItemToggle *)toggle
{
    NSLog(@"MainLayer#onClick_toggle_ok toggle index = %d", toggle.selectedIndex);
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"1-main.bmml"
                                                            eventHandle:self];
        [self addChild:layer];
        
        // 设置按钮标签
        [[layer getControlByName:@"Next"] setText:@"MyNext"];
        
        // 设置disable按钮
        [[layer getControlByName:@"Disable"] setIsEnabled:NO];
        
        // 获取指定精灵
        id action = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:360]];
        [[layer getControlByName:@"image_sprite"] runAction:action];
        
        // 获取指定文本框
        [[layer getControlByName:@"text-input"] setText:@"My input"];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end
