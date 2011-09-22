//
//  TestWebView.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-22.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "TestWebViewLayer.h"
#import "CCBalsamiqScene.h"
#import "CCBalsamiqLayer.h"
#import "TestAlertLayer.h"
#import "TestRadioLayer.h"

@implementation TestWebViewLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCBalsamiqScene node];
	
	// add layer as a child to scene
	[scene addChild:[TestWebViewLayer node]];
	
	// return the scene
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f
																					 scene:[TestAlertLayer scene]]];
}

- (void)onNextClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f
																					 scene:[TestRadioLayer scene]]];
}

-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)view
{
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [view loadRequest:request];
}

- (void)onWebViewCreated:(UIWebView *)webView name:(NSString *)name
{
	[self loadDocument:@"webviewfile.rtf" inView:webView];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"test-webview.bmml"
												  eventHandle:self
												createdHandle:self]];
	}
	return self;
}

@end