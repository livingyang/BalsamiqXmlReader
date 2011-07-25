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

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)testResource:(ccTime)dt
{
	NSString *xmlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.bmml"];
	
	NSArray *array = [BalsamiqControlData parseData:[NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil]];
	
	[CCBalsamiqLayer layerWithBalsamiqData:array eventHandle:self];
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

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]))
	{
		NSString *xmlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.bmml"];
		
		NSArray *array = [BalsamiqControlData parseData:[NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil]];
		
		for (id ele in array)
		{
			NSLog(@"%@", ele);
		}
		
		balsamiqFontName = @"Vanilla.ttf";
		
		uiLayer = [CCBalsamiqLayer layerWithBalsamiqData:array eventHandle:self];
		
		[self addChild:uiLayer];
	}
	return self;
}

@end
