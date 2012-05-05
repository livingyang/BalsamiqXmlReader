//
//  TestScrollLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestScrollLayer.h"
#import "CCBalsamiqLayer.h"
#import "CCTableLayer.h"

@implementation TestScrollLayer

@synthesize tableLayer;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestScrollLayer node]];

	return scene;
}

- (void)testButton:(id)sender
{
    NSLog(@"CCTableLayer#testButton called!!");
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"6-test-scrolllayer.bmml"
												  eventHandle:self]];
        
        self.tableLayer = [CCTableLayer node];
        self.tableLayer.contentSize = CGSizeMake(200, 200);
        self.tableLayer.position = ccp(100, 100);
        [self.tableLayer addCell:[CCLabelTTF labelWithString:@"test" fontName:@"arial" fontSize:32]];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"test2" fontName:@"arial" fontSize:32];
        label.position = ccp(100, 100);
        [self.tableLayer addCell:label];
        
        CCMenu *menu = [CCMenu menuWithItems:nil];
        menu.position = CGPointZero;
        [menu addChild:[CCMenuItemFont itemFromString:@"Button!"
                                               target:self
                                             selector:@selector(testButton:)]];
        [label addChild:menu];
        
        [self addChild:self.tableLayer];
	}
	return self;
}

- (void)onButton1Click:(id)sender
{
    static BOOL isClick = NO;
    if (isClick == YES)
    {
        return;
    }
    
    isClick = YES;
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"button1" fontName:@"arial" fontSize:32];
    label.position = ccp(-20, -200);
    [self.tableLayer addCell:label];
}

- (void)onButton2Click:(id)sender
{
    self.tableLayer.scrollDirection = ccp(1, 1);
}

@end
