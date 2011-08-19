//
//  CCBalsamiqScene.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-19.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCBalsamiqScene.h"
#import "CCBalsamiqLayer.h"

@implementation CCBalsamiqScene

- (void)setPosition:(CGPoint)pos
{
	CGPoint offsetPos = ccpSub(pos, self.position);
	
	for (CCBalsamiqLayer *layer in balsamiqLayerArray)
	{
		for (UIView *uiView in layer.uiViewArray)
		{
			CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:uiView.center];
			CGPoint prePoint = [self convertToNodeSpace:glPoint];
			CGPoint settedPoint = ccpAdd(prePoint, offsetPos);
			CGPoint uiPoint = [[CCDirector sharedDirector] convertToUI:[self convertToWorldSpace:settedPoint]];
			uiView.center = uiPoint;
		}
	}
	
	[super setPosition:pos];
}

- (void)searchBalsamiqLayer:(CCNode *)node searchDepth:(int)depth
{
	if (depth == 0)
	{
		return;
	}
	
	for (id child in node.children)
	{
		if ([child isKindOfClass:[CCBalsamiqLayer class]])
		{
			[balsamiqLayerArray addObject:child];
		}
		else
		{
			[self searchBalsamiqLayer:child searchDepth:depth - 1];
		}
	}
}

-(void) addChild: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag
{
	[self searchBalsamiqLayer:child searchDepth:layerSearchDepth];
	
	[super addChild:child z:z tag:aTag];
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		balsamiqLayerArray = [[NSMutableArray alloc] init];
		layerSearchDepth = 2;
	}
	return self;
}

- (void) dealloc
{
	[balsamiqLayerArray release];
	[super dealloc];
}


@end
