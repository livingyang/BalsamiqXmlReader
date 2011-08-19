//
//  CCBalsamiqLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCBalsamiqLayer.h"
#import "BalsamiqControlData.h"
#import "CCMenuItemButton.h"
#import "CCLabelFX.h"
#import "UIPaddingTextField.h"

NSString *balsamiqFontName = @"arial";
ccColor3B buttonNormalTextColor = {255, 255, 255};
ccColor3B buttonSelectTextColor = {200, 200, 200};
ccColor3B textInputColor = {200, 200, 200};
NSString *balsamiqRootDir = @"";

//保存根目录下的所有界面数据，以及界面对应的路径
static NSDictionary *bmmlAndPathDic = nil;

typedef struct
{
	CCMenu *menu;
	id eventHandle;
	id createdHandle;
	NSString *fileDir;
}ControlCreateInfo;

#define IMAGE_PREFIX @"image_"
#define TOGGLE_PREFIX @"toggle_"
#define TOGGLE_INDEX @"-1"

#define LABEL_NORMAL_OFFSET_POSITION ccp(3, -2)
#define LABEL_SHADOW_OFFSET_POSITION ccp(8, -2)

@implementation CCBalsamiqLayer : CCLayer

@synthesize uiViewArray;

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

/*!
    @名    称：getBalsamiqFilePath
    @描    述：根据文件名，获取文件路径
    @参    数：fileName
    @返 回 值：
    @备    注：
*/
- (NSString *)getBalsamiqFilePath:(NSString *)fileName
{
	if (bmmlAndPathDic == nil)
	{
		NSLog(@"CCBalsamiqLayer#%@ bmmlAndPathDic is nil", NSStringFromSelector(_cmd));
		return nil;
	}
	NSString *filePath = [bmmlAndPathDic objectForKey:fileName];
	if (filePath == nil)
	{
		return nil;
	}
	
	filePath = [balsamiqRootDir stringByAppendingPathComponent:filePath];
	
	return filePath;
}

//格式字符串的特殊字符替换表
- (NSDictionary *)charReplaceList
{
	static NSDictionary *dic = nil;
	
	if (dic == nil)
	{
		dic = [[NSDictionary alloc] initWithObjectsAndKeys:
			   @" ", @"%20",
			   @"!", @"%21",
			   @"?", @"%3F",
			   @":", @"%3A",
			   @"&", @"%26",
			   nil];
	}
	return dic;
}

- (NSString *)getClearText:(NSString *)text
{
	if (text == nil)
	{
		return nil;
	}
	
	NSArray *replaceStrArray = [[self charReplaceList] allKeys];
	for (NSString *replaceStr in replaceStrArray)
	{
		text = [text stringByReplacingOccurrencesOfString:replaceStr
											   withString:[[self charReplaceList] objectForKey:replaceStr]];
	}
	
	return text;
}

- (ccColor3B)getColor:(int)value
{
	return ccc3(value >> 16,
				(value & 0x00FF00) >> 8,
				value & 0x0000FF);
}

- (UIColor *)getUIColor:(ccColor3B)color alpha:(float)alpha
{
	ccColor4F color4F = ccc4FFromccc3B(color);
	return [UIColor colorWithRed:color4F.r green:color4F.g blue:color4F.b alpha:alpha];
}

- (UIColor *)getUIBackgroundColor:(BalsamiqControlData *)data
{
	ccColor3B backgroundColor = ccWHITE;
	if ([data.propertyDic objectForKey:@"color"] != nil)
	{
		backgroundColor = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	}
	
	float alpha = 1.0f;
	if ([data.propertyDic objectForKey:@"backgroundAlpha"] != nil)
	{
		alpha = [[data.propertyDic objectForKey:@"backgroundAlpha"] floatValue];
	}
	
	return [self getUIColor:backgroundColor alpha:alpha];
}

- (CGSize)getBalsamiqControlSize:(BalsamiqControlData *)data
{
	CGSize size = CGSizeZero;
	
	if ([@"-1" isEqualToString:[data.attributeDic objectForKey:@"w"]])
	{
		size.width = [[data.attributeDic objectForKey:@"measuredW"] intValue];
	}
	else
	{
		size.width = [[data.attributeDic objectForKey:@"w"] intValue];
	}
	
	if ([@"-1" isEqualToString:[data.attributeDic objectForKey:@"h"]])
	{
		size.height = [[data.attributeDic objectForKey:@"measuredH"] intValue];
	}
	else
	{
		size.height = [[data.attributeDic objectForKey:@"h"] intValue];
	}
	
	return size;
}

- (CGPoint)getBalsamiqControlPosition:(BalsamiqControlData *)data
{
	return ccp([[data.attributeDic objectForKey:@"x"] intValue],
			   [[data.attributeDic objectForKey:@"y"] intValue]);
}

- (int)getBalsamiqControlTextSize:(BalsamiqControlData *)data
{
	NSString *sizeStr = [data.propertyDic objectForKey:@"size"];
	int size = (sizeStr == nil) ? 13 : [sizeStr intValue];
	
	return size;
}

- (CCTextAlignment)getBalsamiqControlAlign:(BalsamiqControlData *)data
{
	NSString *align = [data.propertyDic objectForKey:@"align"];
	CCTextAlignment textAlign = CCTextAlignmentLeft;
	if ([align isEqualToString:@"right"])
	{
		textAlign = CCTextAlignmentRight;
	}
	else if ([align isEqualToString:@"center"])
	{
		textAlign = CCTextAlignmentCenter;
	}
	
	return textAlign;
}

- (CGPoint)convertToMidPosition:(CGPoint)nodePosition
					   nodeSize:(CGSize)nodeSize
				nodeAnchorPoint:(CGPoint)nodeAnchorPoint
{
	nodePosition.y = self.contentSize.height - nodePosition.y;
	CGPoint offsetAnchor = ccpSub(ccp(0.5, 0.5), nodeAnchorPoint);
	
	return ccpAdd(nodePosition, ccp(offsetAnchor.x * nodeSize.width, offsetAnchor.y * nodeSize.height));
}

- (CGPoint)getMidPosition:(BalsamiqControlData *)data
{
	return [self convertToMidPosition:[self getBalsamiqControlPosition:data]
							 nodeSize:[self getBalsamiqControlSize:data]
					  nodeAnchorPoint:ccp(0, 1)];
}

////////////////////////////////////////////////////////
#pragma mark 控件创建函数
////////////////////////////////////////////////////////

- (void)createImage:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	//NSString *picPath = [[data.propertyDic objectForKey:@"src"] lastPathComponent];
	NSString *picPath = [createInfo.fileDir stringByAppendingPathComponent:[data.propertyDic objectForKey:@"src"]];
	
	NSString *customID = [data.propertyDic objectForKey:@"customID"];
	if (customID == nil)
	{
		customID = @"";
	}
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	
	if ([customID hasPrefix:IMAGE_PREFIX] ||
		[customID isEqualToString:@""])
	{
		//无名字的情况下，创建图片
		CCSprite *image = [CCSprite spriteWithFile:picPath];
		
		CGSize itemSize = [self getBalsamiqControlSize:data];
		if (CGSizeEqualToSize(image.contentSize, itemSize) == NO)
		{
			image.scaleX = itemSize.width / image.contentSize.width;
			image.scaleY = itemSize.height / image.contentSize.height;
		}
		image.position = [self getMidPosition:data];
		[self addChild:image z:zOrder];
		
		//有名字的图片，需要进行通知
		if ([createInfo.createdHandle respondsToSelector:@selector(onImageCreated:name:)])
		{
			[createInfo.createdHandle onImageCreated:image name:customID];
		}
	}
	else if ([customID hasPrefix:TOGGLE_PREFIX] &&
			 [picPath rangeOfString:TOGGLE_INDEX].length > 0)
	{
		NSAssert(0, @"CCBalsamiqLayer#createImage 暂不支持toggle");
		
		CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:createInfo.eventHandle
														   selector:@selector(toggleCallBack:)
															  items:[CCMenuItemImage itemFromNormalImage:picPath selectedImage:picPath], nil];
		toggle.position = [self getMidPosition:data];
		[createInfo.menu addChild:toggle z:zOrder];
		
		if (createInfo.menu.zOrder < zOrder)
		{
			[createInfo.menu.parent reorderChild:createInfo.menu z:zOrder];
		}
		
		for (int i = 2; YES; ++i)
		{
			NSString *curPicName = [picPath stringByReplacingOccurrencesOfString:TOGGLE_INDEX
																	  withString:[NSString stringWithFormat:@"-%d", i]];
			
			if ([[CCTextureCache sharedTextureCache] addImage:curPicName] == nil)
			{
				break;
			}
			
			[toggle.subItems addObject:[CCMenuItemImage itemFromNormalImage:curPicName selectedImage:curPicName]];
		}
		
		//发送事件
		if ([createInfo.createdHandle respondsToSelector:@selector(onToggleCreated:name:)])
		{
			[createInfo.createdHandle onToggleCreated:toggle name:customID];
		}
	}
	else
	{
		//生成事件名称
		NSString* methodName = [NSString stringWithFormat:@"on%@Click:", customID];
		SEL eventSel = sel_registerName([methodName UTF8String]);
		
		NSAssert([createInfo.eventHandle respondsToSelector:eventSel],
				 @"BalsamiqXmlReader#createImage can't find handle %@ at %s",
				 methodName,
				 object_getClassName(createInfo.eventHandle));
		
		//有名字的情况下，创建按钮
		NSString* pressPicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-press"];
		
		CCMenuItemButton *item = [CCMenuItemButton itemFromNormalImage:picPath 
														 selectedImage:pressPicPath
																target:createInfo.eventHandle
															  selector:eventSel];
		
		CGSize itemSize = [self getBalsamiqControlSize:data];
		if (CGSizeEqualToSize(item.contentSize, itemSize) == NO)
		{
			item.scaleX = itemSize.width / item.contentSize.width;
			item.scaleY = itemSize.height / item.contentSize.height;
		}
		item.position = [self getMidPosition:data];
		
		[createInfo.menu addChild:item z:zOrder];
		if (createInfo.menu.zOrder < zOrder)
		{
			[createInfo.menu.parent reorderChild:createInfo.menu z:zOrder];
		}
		
		//若有文本，则需要生成标签
		NSString *text = [data.propertyDic objectForKey:@"text"];
		if (text != nil)
		{
			[item initLabel:[self getClearText:text] 
				   fontName:balsamiqFontName
				   fontSize:[self getBalsamiqControlTextSize:data]
				normalColor:buttonNormalTextColor 
				selectColor:buttonSelectTextColor
			   disableColor:ccBLACK];
			
			item.label.scaleX = 1 / item.scaleX;
			item.label.scaleY = 1 / item.scaleY;
		}
		
		//发送事件
		if ([createInfo.createdHandle respondsToSelector:@selector(onButtonCreated:name:)])
		{
			[createInfo.createdHandle onButtonCreated:item name:customID];
		}
	}	
}

- (void)createLabel:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	//加入边框显示，若在balsamiq中加入下划线，则加入边框
	NSString *underlineStr = [data.propertyDic objectForKey:@"underline"];
	
	CCLabelTTF *label = nil;
	if (underlineStr != nil && [underlineStr isEqualToString:@"true"])
	{
		label = [CCLabelFX labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
								dimensions:[self getBalsamiqControlSize:data]
								 alignment:[self getBalsamiqControlAlign:data]
								  fontName:balsamiqFontName
								  fontSize:[self getBalsamiqControlTextSize:data]
							  shadowOffset:CGSizeMake(0, 0) 
								shadowBlur:2.0f];
		label.position = [self getMidPosition:data];
		//label.position = ccpAdd([self getMidPosition:data], LABEL_SHADOW_OFFSET_POSITION);
	}
	else
	{
		label = [CCLabelTTF labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
								 dimensions:[self getBalsamiqControlSize:data]
								  alignment:[self getBalsamiqControlAlign:data]
								   fontName:balsamiqFontName
								   fontSize:[self getBalsamiqControlTextSize:data]];
		label.position = [self getMidPosition:data];
		//label.position = ccpAdd([self getMidPosition:data], LABEL_NORMAL_OFFSET_POSITION);
	}
	
	label.color = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	
	[self addChild:label z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
	//发送事件
	if ([createInfo.createdHandle respondsToSelector:@selector(onLabelCreated:name:)])
	{
		[createInfo.createdHandle onLabelCreated:label
											name:[data.propertyDic objectForKey:@"customID"]];
	}
}

/*!
 @名    称：createTextInput
 @描    述：创建文本输入框
 @参    数：data
 @参    数：createInfo
 @返 回 值：
 @备    注：文本输入框的指针保存在layer的userData中
 */
- (void)createTextInput:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	CGRect rect = {[self getBalsamiqControlPosition:data], [self getBalsamiqControlSize:data]};
	rect.origin = [self convertToMidPosition:rect.origin
									nodeSize:rect.size
							 nodeAnchorPoint:ccp(0.5f, 0.5f)];
	rect.origin = [[CCDirector sharedDirector] convertToUI:rect.origin];
	
	UIPaddingTextField *textField = [[[UIPaddingTextField alloc] initWithFrame:rect] autorelease];
	[textField setPaddingLeft:5 paddingTop:4];
	
	//nameTextField.transform = CGAffineTransformMakeRotation(M_PI * (90.0 / 180.0)); // rotate for landscape
	textField.text = [self getClearText:[data.propertyDic objectForKey:@"text"]];
	textField.textColor = [self getUIColor:textInputColor alpha:1.0f];
	textField.textAlignment = [self getBalsamiqControlAlign:data];
	textField.font = [UIFont fontWithName:[balsamiqFontName stringByDeletingPathExtension]
									 size:[self getBalsamiqControlTextSize:data]];
	
	// NOTE: UITextField won't be visible by default without setting backGroundColor & borderStyle
	textField.backgroundColor = [self getUIBackgroundColor:data];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	
	textField.delegate = createInfo.eventHandle; // set this layer as the UITextFieldDelegate
	textField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
	textField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
	textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview:textField];
	
	[uiViewArray addObject:textField];
	
	//发送事件
	if ([createInfo.createdHandle respondsToSelector:@selector(onTextInputCreated:name:)])
	{
		[createInfo.createdHandle onTextInputCreated:textField
												name:[data.propertyDic objectForKey:@"customID"]];
	}
}

- (void)createCanvas:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	CGRect rect = {[self getBalsamiqControlPosition:data], [self getBalsamiqControlSize:data]};
	rect.origin = [self convertToMidPosition:rect.origin
									nodeSize:rect.size
							 nodeAnchorPoint:ccp(0.5f, 0.5f)];
	rect.origin = [[CCDirector sharedDirector] convertToUI:rect.origin];
	
	UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
	webView.backgroundColor = [self getUIBackgroundColor:data];
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview:webView];
	
	[uiViewArray addObject:webView];
	
	//发送事件
	if ([createInfo.createdHandle respondsToSelector:@selector(onWebViewCreated:name:)])
	{
		[createInfo.createdHandle onWebViewCreated:webView
											  name:[data.propertyDic objectForKey:@"customID"]];
	}
}


////////////////////////////////////////////////////////
#pragma mark 继承函数
////////////////////////////////////////////////////////

- (void)onExit
{
	for (UITextField *textField in uiViewArray)
	{
		[textField removeFromSuperview];
	}
	
	[super onExit];
}

- (void) dealloc
{
	[uiViewArray release];
	[super dealloc];
}

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

+ (void)setBalsamiqRootDir:(NSString *)rootDir
{
	if (bmmlAndPathDic == nil)
	{
		balsamiqRootDir = [[NSString alloc] initWithString:[[[NSBundle mainBundle] bundlePath]
															stringByAppendingPathComponent:rootDir]];
		
		BOOL isDir;
		if ([[NSFileManager defaultManager] fileExistsAtPath:balsamiqRootDir isDirectory:&isDir] == NO)
		{
			NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is nil", NSStringFromSelector(_cmd), rootDir);
		}
		else if (isDir == NO)
		{
			NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is not dir", NSStringFromSelector(_cmd), rootDir);
		}

		
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		for (NSString *fileName in [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:balsamiqRootDir error:nil])
		{
			if ([[fileName pathExtension] isEqualToString:@"bmml"])
			{
				NSAssert([dic objectForKey:[fileName lastPathComponent]] == nil,
						 @"CCBalsamiqLayer#%@ fileName = %@ is duplicate with %@",
						 NSStringFromSelector(_cmd),
						 fileName,
						 [dic objectForKey:[fileName lastPathComponent]]);
					
				[dic setValue:fileName forKey:[fileName lastPathComponent]];
			}
		}
		
		bmmlAndPathDic = dic;
		NSLog(@"dic = %@", dic);
	}
}

- (id)initWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle createdHandle:(id)createdHandle
{
	self = [self init];
	if (self != nil)
	{
		uiViewArray = [[NSMutableArray alloc] init];
		
		self.isRelativeAnchorPoint = YES;
		self.anchorPoint = ccp(0, 0);
		
		NSMutableArray *balsamiqData = [BalsamiqControlData getBalsamiqControlData:
										[self getBalsamiqFilePath:fileName]];
		if (balsamiqData == nil)
		{
			NSLog(@"CCBalsamiqLayer#%@ fileName = %@ is nil", NSStringFromSelector(_cmd), fileName);
			return nil;
		}
		
		// 1 初始化layer
		for (BalsamiqControlData *data in balsamiqData)
		{
			NSLog(@"%@", [data.attributeDic objectForKey:@"controlTypeID"]);
			
			if ([@"com.balsamiq.mockups::ModalScreen" isEqualToString:[data.attributeDic objectForKey:@"controlTypeID"]])
			{
				self.contentSize = [self getBalsamiqControlSize:data];
				break;
			}
		}
		
		// 2 生成创建的环境
		CCMenu *menu = [CCMenu menuWithItems:nil];
		[self addChild:menu];
		menu.contentSize = self.contentSize;
		menu.position = ccp(0, 0);
		menu.anchorPoint = ccp(0, 0);
		
		ControlCreateInfo createInfo = 
		{
			menu,
			eventHandle,
			createdHandle,
			[[self getBalsamiqFilePath:fileName] stringByDeletingLastPathComponent],
		};
		
		// 3 生成各个控件
		for (BalsamiqControlData *data in balsamiqData)
		{
			NSString *controlType = [[data.attributeDic objectForKey:@"controlTypeID"]
									 substringFromIndex:[@"com.balsamiq.mockups::" length]];
			
			NSString* methodName = [NSString stringWithFormat:@"create%@:byCreateInfo:", controlType];
			SEL creatorSel = sel_registerName([methodName UTF8String]);
			
			if ([self respondsToSelector:creatorSel])
			{
				objc_msgSend(self, creatorSel, data, createInfo);
			}
		}
	}
	return self;
}

+ (id)layerWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle createdHandle:(id)createdHandle
{
	return [[[CCBalsamiqLayer alloc] initWithBalsamiqFile:fileName
											  eventHandle:eventHandle
											createdHandle:createdHandle] autorelease];
}

@end
