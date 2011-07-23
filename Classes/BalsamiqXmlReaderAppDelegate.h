//
//  BalsamiqXmlReaderAppDelegate.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-20.
//  Copyright LieHuo Tech 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface BalsamiqXmlReaderAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
