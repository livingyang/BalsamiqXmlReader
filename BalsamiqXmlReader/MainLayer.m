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
#import "CCAlertLayer.h"
#import "CCBalsamiqScene.h"

#import "TestAlertLayer.h"
#import "BalsamiqReaderConfig.h"

@implementation MainLayer

+(void)initialize
{
	if (self == [MainLayer class])
	{
        [[BalsamiqReaderConfig instance] loadBalsamiqConfigWithPropertyListFile:@"BalsamiqConfig"];
	}
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCBalsamiqScene node];
	
	// add layer as a child to scene
	[scene addChild:[MainLayer node]];
	
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
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestAlertLayer scene]]];
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
