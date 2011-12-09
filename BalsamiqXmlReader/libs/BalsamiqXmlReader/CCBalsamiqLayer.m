//
//  CCBalsamiqLayer.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCBalsamiqLayer.h"
#import <objc/message.h>
#import "BalsamiqControlData.h"
#import "CCMenuItemButton.h"
#import "UIPaddingTextField.h"
#import "RadioManager.h"
#import "CCLoadingBar.h"
#import "BalsamiqFileParser.h"
#import "BalsamiqReaderConfig.h"

typedef struct
{
	CCMenu *menu;
	id eventHandle;
	NSString *fileDir;
}ControlCreateInfo;

#define IMAGE_PREFIX @"image_"
#define RADIO_PREFIX @"radio_"

@implementation CCBalsamiqLayer : CCLayer

@synthesize nameAndControlDic, uiViewArray;

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

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

- (id)createButton:(BalsamiqControlData *)data
	  byCreateInfo:(ControlCreateInfo)createInfo
			target:(id)target
			   sel:(SEL)sel
{
	NSString *picPath = [createInfo.fileDir stringByAppendingPathComponent:[data.propertyDic objectForKey:@"src"]];
	
	NSString *customID = [data.propertyDic objectForKey:@"customID"];
	if (customID == nil)
	{
		customID = @"";
	}
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	
	NSString* pressPicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-press"];
	
	CCMenuItemButton *item = [CCMenuItemButton itemFromNormalImage:picPath 
													 selectedImage:pressPicPath
															target:target
														  selector:sel];
	
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
			   fontName:[BalsamiqReaderConfig instance].balsamiqFontName
			   fontSize:[self getBalsamiqControlTextSize:data]
			normalColor:[BalsamiqReaderConfig instance].buttonNormalTextColor 
			selectColor:[BalsamiqReaderConfig instance].buttonSelectTextColor
		   disableColor:ccBLACK];
		
		item.label.scaleX = 1 / item.scaleX;
		item.label.scaleY = 1 / item.scaleY;
	}
	
	return item;
}

- (void)onRadioItemClick:(id)sender
{
	for (RadioManager *chkManager in [groupAndRadioDic allValues])
	{
		if ([chkManager isSubitem:sender])
		{
			[chkManager selectItem:sender];
		}
	}
}

- (void)setControl:(id)control withName:(NSString *)name
{
    if (control == nil || name == nil || [name isEqualToString:@""])
    {
        return;
    }
    
    NSAssert([nameAndControlDic objectForKey:name] == nil, @"CCBalsamiqLayer#addControl duplicate name = %@", name);
    
    [nameAndControlDic setObject:control forKey:name];
}

////////////////////////////////////////////////////////
#pragma mark 控件创建函数
////////////////////////////////////////////////////////

- (void)createImage:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	//NSString *picPath = [[data.propertyDic objectForKey:@"src"] lastPathComponent];
	NSString *picPath = [createInfo.fileDir stringByAppendingPathComponent:[data.propertyDic objectForKey:@"src"]];
	
	NSString *customID = [data.propertyDic objectForKey:@"customID"];
    customID = (customID == nil) ? @"" : customID;
	
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
		
        [self setControl:image withName:customID];
	}
	else if ([customID hasPrefix:RADIO_PREFIX])
	{
		NSArray *radioParamArray = [customID componentsSeparatedByString:@"_"];
		NSAssert(radioParamArray.count == 3,
				 @"CCBalsamiqLayer#createImage radio param count = %d",
				 radioParamArray.count);
		
		RadioManager *chkManager = [groupAndRadioDic objectForKey:[radioParamArray objectAtIndex:1]];
		if (chkManager == nil)
		{
			chkManager = [[[RadioManager alloc] init] autorelease];
			chkManager.delegate = createInfo.eventHandle;
			[groupAndRadioDic setValue:chkManager forKey:[radioParamArray objectAtIndex:1]];
		}
		
		id button = [self createButton:data
						  byCreateInfo:createInfo
								target:self
								   sel:@selector(onRadioItemClick:)];
		
		[chkManager addItem:button withInfo:customID];
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
		
		id button = [self createButton:data
						  byCreateInfo:createInfo
								target:createInfo.eventHandle
								   sel:eventSel];
		
        [self setControl:button withName:customID];
	}	
}

- (void)createLabel:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
                                         dimensions:[self getBalsamiqControlSize:data]
                                          alignment:[self getBalsamiqControlAlign:data]
                                           fontName:[BalsamiqReaderConfig instance].balsamiqFontName
                                           fontSize:[self getBalsamiqControlTextSize:data]];
    label.position = [self getMidPosition:data];
	
	label.color = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	
	[self addChild:label z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
    [self setControl:label withName:[data.propertyDic objectForKey:@"customID"]];
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
	textField.textColor = [self getUIColor:[BalsamiqReaderConfig instance].textInputColor alpha:1.0f];
	textField.textAlignment = [self getBalsamiqControlAlign:data];
	textField.font = [UIFont fontWithName:[[BalsamiqReaderConfig instance].balsamiqFontName stringByDeletingPathExtension]
									 size:[self getBalsamiqControlTextSize:data]];
	
	// NOTE: UITextField won't be visible by default without setting backGroundColor & borderStyle
	//textField.backgroundColor = [self getUIBackgroundColor:data];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	
	textField.delegate = createInfo.eventHandle; // set this layer as the UITextFieldDelegate
	textField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
	textField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
	textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview:textField];
	
	[uiViewArray addObject:textField];
	
    [self setControl:textField withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createCanvas:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	CGRect rect = {[self getBalsamiqControlPosition:data], [self getBalsamiqControlSize:data]};
	rect.origin = [self convertToMidPosition:rect.origin
									nodeSize:rect.size
							 nodeAnchorPoint:ccp(0.5f, 0.5f)];
	rect.origin = [[CCDirector sharedDirector] convertToUI:rect.origin];
	
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:rect] autorelease];
	webView.backgroundColor = [self getUIBackgroundColor:data];
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview:webView];
	
	[uiViewArray addObject:webView];
	
    [self setControl:webView withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createIcon:(BalsamiqControlData *)data byCreateInfo:(ControlCreateInfo)createInfo
{
	NSString *customID = [data.propertyDic objectForKey:@"customID"];
	if (customID == nil)
	{
		customID = @"";
	}
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	
	//无名字的情况下，创建图片
	CCLoadingBar *loadingBar = [CCLoadingBar spriteWithFile:[BalsamiqReaderConfig instance].loadingBarPic];
	[loadingBar setBarDisplayCycle:1.0 barLeafCount:12];
	
	CGSize itemSize = [self getBalsamiqControlSize:data];
	if (CGSizeEqualToSize(loadingBar.contentSize, itemSize) == NO)
	{
		[loadingBar setBarSize:itemSize.width];
	}
	loadingBar.position = [self getMidPosition:data];
	[self addChild:loadingBar z:zOrder];
	
    [self setControl:loadingBar withName:customID];
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
    [nameAndControlDic release];
	[groupAndRadioDic release];
	[uiViewArray release];
	[super dealloc];
}

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

- (id)initWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle
{
	self = [self init];
	if (self != nil)
	{
        nameAndControlDic = [[NSMutableDictionary alloc] init];
		uiViewArray = [[NSMutableArray alloc] init];
		groupAndRadioDic = [[NSMutableDictionary alloc] init];
		
		self.isRelativeAnchorPoint = YES;
		self.anchorPoint = ccp(0, 0);
		
		NSMutableArray *balsamiqData = [[BalsamiqFileParser instance] getControlsData:
                                        [[BalsamiqReaderConfig instance] getBalsamiqFilePath:fileName]];
		
        if (balsamiqData == nil)
		{
			NSLog(@"CCBalsamiqLayer#%@ fileName = %@ is nil", NSStringFromSelector(_cmd), fileName);
			return nil;
		}
		
		// 1 初始化layer
		for (BalsamiqControlData *data in balsamiqData)
		{
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
			[[[BalsamiqReaderConfig instance] getBalsamiqFilePath:fileName] stringByDeletingLastPathComponent],
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
		
		// 4 初始化Radio控件
		for (RadioManager *radioManager in [groupAndRadioDic allValues])
		{
			[radioManager selectFirstItem];
		}
        
        // 5 打印各个控件信息
        //CCLOG(@"Controls = %@", self.nameAndControlDic);
	}
	return self;
}

+ (id)layerWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle
{
	return [[[CCBalsamiqLayer alloc] initWithBalsamiqFile:fileName
											  eventHandle:eventHandle] autorelease];
}

- (id)getControlByName:(NSString *)name
{
    return [self.nameAndControlDic objectForKey:name];
}

@end
