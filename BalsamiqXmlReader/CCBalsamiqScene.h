//
//  CCBalsamiqScene.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-19.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBalsamiqScene : CCScene
{
	/*!
		@名    称：balsamiqLayerArray
		@描    述：存放属于本节点的CCBalsamiqLayer子节点
		@备    注：
	*/
	NSMutableArray *balsamiqLayerArray;
	
	/*!
		@名    称：layerSearchDepth
		@描    述：在加入的子节点中，寻找CCBalsamiqLayer的层数
		@备    注：默认为2
	*/
	int layerSearchDepth;
}

@end
