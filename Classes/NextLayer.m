//
//  NextLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-8-15.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "NextLayer.h"

#import "BalsamiqControlData.h"
#import "CCBalsamiqLayer.h"
#import "CCAlertLayer.h"
#import "CCBalsamiqScene.h"

#import "HelloWorldLayer.h"

@implementation NextLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCBalsamiqScene node];

	// add layer as a child to scene
	[scene addChild:[NextLayer node]];
	
	// return the scene
	return scene;
}

- (void)onBackClick:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.0f
																					 scene:[HelloWorldLayer scene]]];
}

- (void)onPopAlertClick:(id)sender
{
	[CCAlertLayer showAlert:@"alert-yes-no.bmml"
				 parentNode:self];
}

- (void)onShowAlertClick:(id)sender
{
	[CCAlertLayer showAlert:@"alert-yes-no.bmml"
				 parentNode:self
				  showModal:kNormalShowModal];
}

- (void)onYesClick:(id)sender
{
	[CCAlertLayer showAlert:@"alert-yes-no.bmml"
				 parentNode:self];
}

- (void)onNoClick:(id)sender
{
	[CCAlertLayer removeAlertFromNode:sender];
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
	[self loadDocument:@"box2d.pdf" inView:webView];
}

-(id) init
{
	if( (self=[super init]))
	{
		[self addChild:[CCBalsamiqLayer layerWithBalsamiqFile:@"next.bmml"
												  eventHandle:self
												createdHandle:self]];
	}
	return self;
}

@end
