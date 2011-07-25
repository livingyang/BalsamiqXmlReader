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
#import "BalsamiqLayerTextInputManager.h"

NSString *balsamiqFontName = @"arial";
ccColor3B buttonNormalTextColor = {255, 255, 255};
ccColor3B buttonSelectTextColor = {200, 200, 200};
ccColor3B textInputColor = {200, 200, 200};

typedef struct
{
	CCMenu *menu;
	id eventHandle;
}ControlCreateInfo;

#define IMAGE_PREFIX @"image_"
#define TOGGLE_PREFIX @"toggle_"
#define TOGGLE_INDEX @"-1"

@implementation CCBalsamiqLayer : CCLayer

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
	NSString *picName = [[data.propertyDic objectForKey:@"src"] lastPathComponent];
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
		CCSprite *image = [CCSprite spriteWithFile:picName];
		
		CGSize itemSize = [self getBalsamiqControlSize:data];
		if (CGSizeEqualToSize(image.contentSize, itemSize) == NO)
		{
			image.scaleX = itemSize.width / image.contentSize.width;
			image.scaleY = itemSize.height / image.contentSize.height;
		}
		image.position = [self getMidPosition:data];
		[self addChild:image z:zOrder];
		
		//有名字的图片，需要进行通知
		if ([createInfo.eventHandle respondsToSelector:@selector(onImageCreated:name:)])
		{
			[createInfo.eventHandle onImageCreated:image name:customID];
		}
	}
	else if ([customID hasPrefix:TOGGLE_PREFIX] &&
			 [picName rangeOfString:TOGGLE_INDEX].length > 0)
	{
		CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:createInfo.eventHandle
														   selector:@selector(toggleCallBack:)
															  items:[CCMenuItemImage itemFromNormalImage:picName selectedImage:picName], nil];
		toggle.position = [self getMidPosition:data];
		[createInfo.menu addChild:toggle z:zOrder];
		
		if (createInfo.menu.zOrder < zOrder)
		{
			[createInfo.menu.parent reorderChild:createInfo.menu z:zOrder];
		}
		
		for (int i = 2; YES; ++i)
		{
			NSString *curPicName = [picName stringByReplacingOccurrencesOfString:TOGGLE_INDEX
																	  withString:[NSString stringWithFormat:@"-%d", i]];
			
			if ([[CCTextureCache sharedTextureCache] addImage:curPicName] == nil)
			{
				break;
			}
			
			[toggle.subItems addObject:[CCMenuItemImage itemFromNormalImage:curPicName selectedImage:curPicName]];
		}
		
		//发送事件
		if ([createInfo.eventHandle respondsToSelector:@selector(onToggleCreated:name:)])
		{
			[createInfo.eventHandle onToggleCreated:toggle name:customID];
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
		NSString* pressPicName = [picName stringByReplacingOccurrencesOfString:@"-normal" withString:@"-press"];
		
		CCMenuItemButton *item = [CCMenuItemButton itemFromNormalImage:picName 
														 selectedImage:pressPicName
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
		if ([createInfo.eventHandle respondsToSelector:@selector(onButtonCreated:name:)])
		{
			[createInfo.eventHandle onButtonCreated:item name:customID];
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
	}
	else
	{
		label = [CCLabelTTF labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
								 dimensions:[self getBalsamiqControlSize:data]
								  alignment:[self getBalsamiqControlAlign:data]
								   fontName:balsamiqFontName
								   fontSize:[self getBalsamiqControlTextSize:data]];
	}
	
	label.position = [self getMidPosition:data];
	label.color = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	
	[self addChild:label z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
	//发送事件
	if ([createInfo.eventHandle respondsToSelector:@selector(onLabelCreated:name:)])
	{
		[createInfo.eventHandle onLabelCreated:label
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
	ccColor3B backgroundColor = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	textField.backgroundColor = [self getUIColor:backgroundColor
											   alpha:[[data.propertyDic objectForKey:@"backgroundAlpha"] floatValue]];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	
	textField.delegate = createInfo.eventHandle; // set this layer as the UITextFieldDelegate
	textField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
	textField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
	textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview:textField];
	
	[[BalsamiqLayerTextInputManager instance] addTextInput:textField managedBy:self];
	
	//发送事件
	if ([createInfo.eventHandle respondsToSelector:@selector(onTextInputCreated:name:)])
	{
		[createInfo.eventHandle onTextInputCreated:textField
											  name:[data.propertyDic objectForKey:@"customID"]];
	}
}

////////////////////////////////////////////////////////
#pragma mark 继承函数
////////////////////////////////////////////////////////

- (void) dealloc
{
	[[BalsamiqLayerTextInputManager instance] removeTextInputManager:self];
	[super dealloc];
}

////////////////////////////////////////////////////////
#pragma mark 公共函数
////////////////////////////////////////////////////////

- (id)initWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id)handle
{
	self = [self init];
	if (self != nil)
	{
		self.isRelativeAnchorPoint = YES;
		self.anchorPoint = ccp(0, 0);
		
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
			handle,
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

+ (id)layerWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id)handle
{
	return [[[CCBalsamiqLayer alloc] initWithBalsamiqData:balsamiqData eventHandle:handle] autorelease];
}

@end
