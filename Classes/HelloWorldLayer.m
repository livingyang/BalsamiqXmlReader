//
//  HelloWorldLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright LieHuo Tech 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#import "BalsamiqControlData.h"
#import "CCBalsamiqLayer.h"
#import "CCAlertLayer.h"
#import "CCBalsamiqScene.h"

#import "NextLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
//	[CCBalsamiqLayer setBalsamiqRootDir:@"UI"];
	[CCBalsamiqLayer setBalsamiqConfigWithPropertyListFile:@"BalsamiqConfig"];
	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCBalsamiqScene node];
	
	// add layer as a child to scene
	[scene addChild:[HelloWorldLayer node]];
	
	// return the scene
	return scene;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
	NSLog(@"textField text = %@", textField.text);
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.0f
																					 scene:[NextLayer scene]]];
}

- (void)onButtonClick:(id)sender
{
	[CCAlertLayer showAlert:@"alert-ok.bmml"
				 parentNode:self
				  labelInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"title", @"Title",
							 @"please comfirm", @"Message",
							 nil]
				 buttonInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"OooooK", @"Ok",
							 nil]];
}

- (void)onOkClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"main.bmml"
												  eventHandle:self
												createdHandle:self]];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end
