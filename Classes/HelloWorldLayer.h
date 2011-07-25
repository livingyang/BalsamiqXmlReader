//
//  HelloWorldLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright LieHuo Tech 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "BalsamiqXmlDef.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <BalsamiqReaderDelegate>
{
	CCLayer *uiLayer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
