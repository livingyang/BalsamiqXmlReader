//
//  TestScrollLayer.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 12-5-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestScrollLayer.h"
#import "CCBalsamiqLayer.h"

@implementation TestScrollLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	[scene addChild:[TestScrollLayer node]];

	return scene;
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"2-test-alert.bmml"
												  eventHandle:self]];
	}
	return self;
}

@end
