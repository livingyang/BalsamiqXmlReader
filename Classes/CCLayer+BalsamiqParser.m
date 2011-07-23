//
//  CCLayer+BalsamiqParser.m
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import "CCLayer+BalsamiqParser.h"
#import "BalsamiqControlData.h"
#import "CCMenuItemButton.h"
#import "CCLabelFX.h"

NSString *balsamiqFontName = @"arial";
ccColor3B buttonNormalTextColor = {255, 255, 255};
ccColor3B buttonSelectTextColor = {200, 200, 200};

typedef struct
{
	CCMenu *menu;
	id eventHandle;
}ControlCreateInfo;

@implementation CCLayer(BalsamiqParser)

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

- (CGPoint)getMidPosition:(BalsamiqControlData *)data
{
	CGPoint dataPositon = [self getBalsamiqControlPosition:data];
	dataPositon.y = self.contentSize.height - dataPositon.y;
	
	CGSize dataSize = [self getBalsamiqControlSize:data];
	
	CGPoint offsetAnchor = ccpSub(ccp(0.5, 0.5), ccp(0, 1));
	
	return ccpAdd(dataPositon, ccp(offsetAnchor.x * dataSize.width, offsetAnchor.y * dataSize.height));
}

- (void)setLayerInfo:(BalsamiqControlData *)layerInfo
{
	self.contentSize = [self getBalsamiqControlSize:layerInfo];
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
			NSString *size = [data.propertyDic objectForKey:@"size"];
			
			[item initLabel:[self getClearText:text] 
				   fontName:balsamiqFontName
				   fontSize:(size == nil) ? 13 : [size intValue]
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
	NSString *sizeStr = [data.propertyDic objectForKey:@"size"];
	int size = (sizeStr == nil) ? 13 : [sizeStr intValue];
	
	//加入对齐控制
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
	
	//加入边框显示，若在balsamiq中加入下划线，则加入边框
	NSString *underlineStr = [data.propertyDic objectForKey:@"underline"];
	
	CCLabelTTF *label = nil;
	if (underlineStr != nil && [underlineStr isEqualToString:@"true"])
	{
		label = [CCLabelFX labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
								dimensions:[self getBalsamiqControlSize:data]
								 alignment:textAlign
								  fontName:balsamiqFontName
								  fontSize:size
							  shadowOffset:CGSizeMake(0, 0) 
								shadowBlur:2.0f];
	}
	else
	{
		label = [CCLabelTTF labelWithString:[self getClearText:[data.propertyDic objectForKey:@"text"]]
								 dimensions:[self getBalsamiqControlSize:data]
								  alignment:textAlign
								   fontName:balsamiqFontName
								   fontSize:size];
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
				[self setLayerInfo:data];
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
	return [[[CCLayer alloc] initWithBalsamiqData:balsamiqData eventHandle:handle] autorelease];
}

@end
