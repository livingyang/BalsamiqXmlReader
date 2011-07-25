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
		size.height = [[data.attributeDic objectForKey:@"measuredH"] intValue];
	}
	else
	{
		size.width = [[data.attributeDic objectForKey:@"w"] intValue];
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
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	
	if (customID == nil || 
		[customID isEqualToString:@""] ||
		[customID rangeOfString:@"image_"].length != 0)
	{
		//无名字的情况下，创建图片
		CCSprite *image = [CCSprite spriteWithFile:picName];
		
		CGSize imageSize = [self getBalsamiqControlSize:data];
		if (CGSizeEqualToSize(image.contentSize, imageSize) == NO)
		{
			image.scaleX = imageSize.width / image.contentSize.width;
			image.scaleY = imageSize.height / image.contentSize.height;
		}
		image.position = [self getMidPosition:data];
		[self addChild:image z:zOrder];
		
		//有名字的图片，需要进行通知
		if ([createInfo.eventHandle respondsToSelector:@selector(onImageCreated:name:)])
		{
			[createInfo.eventHandle onImageCreated:image name:customID];
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
	
	UIPaddingTextField *nameTextField = [[[UIPaddingTextField alloc] initWithFrame:rect] autorelease];
	[nameTextField setPaddingLeft:5 paddingTop:4];
	
	//nameTextField.transform = CGAffineTransformMakeRotation(M_PI * (90.0 / 180.0)); // rotate for landscape
	nameTextField.text = [self getClearText:[data.propertyDic objectForKey:@"text"]];
	nameTextField.textColor = [self getUIColor:textInputColor alpha:1.0f];
	nameTextField.textAlignment = [self getBalsamiqControlAlign:data];
	nameTextField.font = [UIFont fontWithName:[balsamiqFontName stringByDeletingPathExtension]
										 size:[self getBalsamiqControlTextSize:data]];
	
	// NOTE: UITextField won't be visible by default without setting backGroundColor & borderStyle
	ccColor3B backgroundColor = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	nameTextField.backgroundColor = [self getUIColor:backgroundColor
											   alpha:[[data.propertyDic objectForKey:@"backgroundAlpha"] floatValue]];
	nameTextField.borderStyle = UITextBorderStyleNone;
	
	nameTextField.delegate = createInfo.eventHandle; // set this layer as the UITextFieldDelegate
	nameTextField.returnKeyType = UIReturnKeyDone; // add the 'done' key to the keyboard
	nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // switch of auto correction
	nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	
	[[BalsamiqLayerTextInputManager instance] addTextInput:nameTextField managedBy:self];
	
	// add the textField to the main game openGLVview
	[[[CCDirector sharedDirector] openGLView] addSubview: nameTextField];
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

- (id)initWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle
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

+ (id)layerWithBalsamiqData:(NSArray *)balsamiqData eventHandle:(id<BalsamiqReaderDelegate>)handle
{
	return [[[CCBalsamiqLayer alloc] initWithBalsamiqData:balsamiqData eventHandle:handle] autorelease];
}

@end
