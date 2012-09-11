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

#import "TestLabelLayer.h"
#import "BalsamiqReaderConfig.h"

@implementation MainLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[MainLayer node]];
	return scene;
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestLabelLayer scene]]];
}

- (void)onDisableClick:(id)sender
{}

- (void)onClick_toggle_ok:(CCMenuItemToggle *)toggle
{
    NSLog(@"MainLayer#onClick_toggle_ok toggle index = %d", toggle.selectedIndex);
    
    NSLog(@"toggle balsamiqLayer = %@", [CCBalsamiqLayer getBalsamiqLayerFromChild:toggle]);
}

- (void)onRandomBarClick:(id)sender
{
    barTest.percentage = arc4random() % 101;
}

- (void)onRotateSpriteClick:(id)sender
{
    int tagAction = 100;
    if ([sprTest getActionByTag:tagAction] != nil)
    {
        [sprTest stopActionByTag:tagAction];
        return;
    }
    
    CCRepeatForever *action = [CCRepeatForever actionWithAction:
                               [CCRotateBy actionWithDuration:1.0f angle:360]];
    action.tag = tagAction;
    [sprTest runAction:action];
}

-(id) init
{
	if( (self=[super init]))
	{
        CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:@"1-main.bmml"
                                                            eventHandle:self];
        [self addChild:layer];
        
        [[layer getControlByName:@"Next"] setText:@"MyNext"];
        [[layer getControlByName:@"Disable"] setIsEnabled:NO];
        
        sprTest = [layer getControlByName:@"image_sprite"];
        barTest = [layer getControlByName:@"bar_test"];
	}
	return self;
}

@end
