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
#import "CCTextField.h"
#import "CCTableLayer.h"
#import "CCLoadingBar.h"
#import "BalsamiqFileParser.h"
#import "BalsamiqReaderConfig.h"

#define IMAGE_PREFIX @"image_"
#define RADIO_PREFIX @"radio_"

@implementation CCBalsamiqLayer : CCLayer

@synthesize bmmlFilePath;
@synthesize uiViewArray;

+(void)initialize
{
	if (self == [CCBalsamiqLayer class])
	{
        [[BalsamiqReaderConfig instance] loadBalsamiqConfigWithPropertyListFile:@"BalsamiqConfig"];
	}
}

////////////////////////////////////////////////////////
#pragma mark 私有函数
////////////////////////////////////////////////////////

//格式字符串的特殊字符替换表
- (NSString *)getDecodeText:(NSString *)text
{
    return [text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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

- (CGPoint)parseDataPosition:(BalsamiqControlData *)data
{
	return ccp([[data.attributeDic objectForKey:@"x"] intValue],
			   [[data.attributeDic objectForKey:@"y"] intValue]);
}

- (CGPoint)getBalsamiqControlPosition:(BalsamiqControlData *)data
{
    return ccpSub([self parseDataPosition:data], originControlPosition);
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

- (CGPoint)getAnchorPointWithTextAlignment:(CCTextAlignment)align
{
    switch (align)
    {
        case CCTextAlignmentLeft:
        {
            return ccp(0.0f, 0.5f);
        }break;
        case CCTextAlignmentCenter:
        {
            return ccp(0.5f, 0.5f);
        }break;
        case CCTextAlignmentRight:
        {
            return ccp(1.0f, 0.5f);
        }break;
        default:
        {
            return ccp(0.5f, 0.5f);
        }break;
    }
}

- (CGPoint)convertControlPosition:(CGPoint)controlPosition 
                         nodeSize:(CGSize)nodeSize
                  withAnchorPoint:(CGPoint)anchorPoint
{
    controlPosition.y = self.contentSize.height - controlPosition.y;
	CGPoint offsetAnchor = ccpSub(anchorPoint, ccp(0, 1));
    
	return ccpAdd(controlPosition, ccp(offsetAnchor.x * nodeSize.width, offsetAnchor.y * nodeSize.height));
}

- (CGPoint)getMidPosition:(BalsamiqControlData *)data
{
    return [self convertControlPosition:[self getBalsamiqControlPosition:data]
                               nodeSize:[self getBalsamiqControlSize:data]
                        withAnchorPoint:ccp(0.5f, 0.5f)];
}

- (NSString *)getPicPath:(NSString *)src
{
    return [[bmmlFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:src];
}

- (id)createButton:(BalsamiqControlData *)data
			target:(id)target
			   sel:(SEL)sel
{
	NSString *picPath = [self getPicPath:[data.propertyDic objectForKey:@"src"]];
    
    NSString* pressPicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-press"];
	NSString* disablePicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-disable"];
	
	CCMenuItemButton *item = [CCMenuItemButton itemFromNormalImage:picPath 
													 selectedImage:pressPicPath
                                                     disabledImage:disablePicPath
															target:target
														  selector:sel];
	
	CGSize itemSize = [self getBalsamiqControlSize:data];
	if (CGSizeEqualToSize(item.contentSize, itemSize) == NO)
	{
		item.scaleX = itemSize.width / item.contentSize.width;
		item.scaleY = itemSize.height / item.contentSize.height;
	}
	item.position = [self getMidPosition:data];
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	[controlMenu addChild:item z:zOrder];
	if (controlMenu.zOrder < zOrder)
	{
		[controlMenu.parent reorderChild:controlMenu z:zOrder];
	}
	
	//若有文本，则需要生成标签
	NSString *text = [data.propertyDic objectForKey:@"text"];
	if (text != nil)
	{
		[item initLabel:[self getDecodeText:text] 
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
    for (NSString *radioGroup in [groupAndRadioDic allKeys])
    {
        RadioManager *chkManager = [groupAndRadioDic objectForKey:radioGroup];
        
		if ([chkManager isSubitem:sender])
		{
			[chkManager selectItem:sender];
            
            SEL radioClickSel = NSSelectorFromString([NSString stringWithFormat:@"on%@RadioSelected:", radioGroup]);
            if ([eventHandle_ respondsToSelector:radioClickSel])
            {
                [eventHandle_ performSelector:radioClickSel
                                   withObject:chkManager.selectedItemInfo];
            }
            
            break;
		}
	}
}

- (void)setControl:(id)control withName:(NSString *)name
{
    if (control == nil || name == nil || [name isEqualToString:@""])
    {
        return;
    }
    
    NSAssert([nameAndControlDic objectForKey:name] == nil,
             @"CCBalsamiqLayer#addControl duplicate name = %@, bmml file = %@",
             name,
             self.bmmlFilePath);
    
    [nameAndControlDic setObject:control forKey:name];
}

- (void)onNoneHandleButtonClick:(id)sender
{
    NSString *name = nil;
    for (id key in [nameAndControlDic allKeys])
    {
        if ([self getControlByName:key] == sender)
        {
            name = key;
            break;
        }
    }
    
    NSLog(@"CCBalsamiqLayer#onNoneHandleButtonClick name = %@, sender = %@", name, sender);
}

////////////////////////////////////////////////////////
#pragma mark 控件创建函数
////////////////////////////////////////////////////////

- (void)createImage:(BalsamiqControlData *)data
{
	NSString *picPath = [self getPicPath:[data.propertyDic objectForKey:@"src"]];
	
	NSString *customID = [data.propertyDic objectForKey:@"customID"];
    customID = (customID == nil) ? @"" : customID;
	
	int zOrder = [[data.attributeDic objectForKey:@"zOrder"] intValue];
	
	if ([customID hasPrefix:IMAGE_PREFIX] ||
		[customID isEqualToString:@""])
	{
		//无名字的情况下，创建图片
		CCSprite *image = [CCSprite spriteWithFile:picPath];
        [[CCTextureCache sharedTextureCache] removeTexture:image.texture];
		
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
			[groupAndRadioDic setValue:chkManager forKey:[radioParamArray objectAtIndex:1]];
		}
		
		id button = [self createButton:data
								target:self
								   sel:@selector(onRadioItemClick:)];
		
		[chkManager addItem:button withInfo:customID];
	}
	else
	{
		//生成事件名称
		NSString* methodName = [NSString stringWithFormat:@"on%@Click:", customID];
		SEL eventSel = sel_registerName([methodName UTF8String]);
		
        if ([eventHandle_ respondsToSelector:eventSel])
        {
            [self setControl:[self createButton:data
                                         target:eventHandle_
                                            sel:eventSel]
                    withName:customID];
        }
        else
        {
            [self setControl:[self createButton:data
                                         target:self
                                            sel:@selector(onNoneHandleButtonClick:)]
                    withName:customID];
            
            NSLog(@"CCBalsamiqLayer#createImage NoneHandleButton created, name = %@, handle = %@, methodName = %@",
                  customID, eventHandle_, methodName);
        }
	}	
}

- (void)createLabel:(BalsamiqControlData *)data
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:[self getDecodeText:[data.propertyDic objectForKey:@"text"]]
                                           fontName:[BalsamiqReaderConfig instance].balsamiqFontName
                                           fontSize:[self getBalsamiqControlTextSize:data]];
    
    label.anchorPoint = [self getAnchorPointWithTextAlignment:[self getBalsamiqControlAlign:data]];
    label.position = [self convertControlPosition:[self getBalsamiqControlPosition:data]
                                         nodeSize:[self getBalsamiqControlSize:data]
                                  withAnchorPoint:label.anchorPoint];
	
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
 @备    注：
 */
- (void)createTextInput:(BalsamiqControlData *)data
{
    CCTextField *textField = [CCTextField textFieldWithFieldSize:[self getBalsamiqControlSize:data]
                                                          fontName:[BalsamiqReaderConfig instance].balsamiqFontName
                                                       andFontSize:[self getBalsamiqControlTextSize:data]];
    textField.position = [self getMidPosition:data];
    textField.anchorPoint = ccp(0.5f, 0.5f);
    textField.text = [self getDecodeText:[data.propertyDic objectForKey:@"text"]];
	[self addChild:textField z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
    [self setControl:textField withName:[data.propertyDic objectForKey:@"customID"]];    
}

- (void)createTextArea:(BalsamiqControlData *)data
{
	CGRect rect = {[self getBalsamiqControlPosition:data], [self getBalsamiqControlSize:data]};
	rect.origin = [self convertControlPosition:rect.origin 
                                      nodeSize:rect.size
                               withAnchorPoint:ccp(0, 1)];
	rect.origin = [[CCDirector sharedDirector] convertToUI:rect.origin];
	
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:rect] autorelease];
	webView.backgroundColor = [self getUIBackgroundColor:data];
	
	[uiViewArray addObject:webView];
	
    [self setControl:webView withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createCanvas:(BalsamiqControlData *)data
{
    CCTableLayer *tableLayer = [CCTableLayer node];
    tableLayer.contentSize = [self getBalsamiqControlSize:data];
    tableLayer.anchorPoint = ccp(0.5f, 0.5f);
    tableLayer.position = [self getMidPosition:data];
    
    [self addChild:tableLayer z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
    [self setControl:tableLayer withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createIcon:(BalsamiqControlData *)data
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

- (void)createFieldSet:(BalsamiqControlData *)data
{
    NSString *bmmlFileName = [self getDecodeText:[data.propertyDic objectForKey:@"text"]];
    
    CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:bmmlFileName eventHandle:eventHandle_];
    layer.position = [self convertControlPosition:[self getBalsamiqControlPosition:data]
                                         nodeSize:[self getBalsamiqControlSize:data]
                                  withAnchorPoint:ccp(0, 0)];
    [self addChild:layer z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
    [self setControl:layer withName:[data.propertyDic objectForKey:@"customID"]];
    
    if (CGSizeEqualToSize(layer.contentSize, [self getBalsamiqControlSize:data]) == false)
    {
        CCLOG(@"CCBalsamiqLayer#createFieldSet link layer contentSize is not equal, link layer = %@, id = %@",
              bmmlFileName,
              [data.propertyDic objectForKey:@"customID"]);
    }
}

////////////////////////////////////////////////////////
#pragma mark 继承函数
////////////////////////////////////////////////////////

- (void)onEnter
{
	for (UIView *view in uiViewArray)
	{
        [[[CCDirector sharedDirector] openGLView] addSubview:view];
    }
    
    [super onEnter];
}

- (void)onExit
{
	for (UIView *view in uiViewArray)
	{
		[view removeFromSuperview];
	}
	
	[super onExit];
}

- (void) dealloc
{
    [bmmlFilePath release];
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
        eventHandle_ = eventHandle;
        originControlPosition = ccp(0, 0);
		
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
                originControlPosition = [self parseDataPosition:data];
				break;
			}
		}
		
		// 2 生成创建的环境
		CCMenu *menu = [CCMenu menuWithItems:nil];
		[self addChild:menu];
		menu.contentSize = self.contentSize;
		menu.position = ccp(0, 0);
		menu.anchorPoint = ccp(0, 0);
        
        controlMenu = menu;
        bmmlFilePath = [[NSString alloc] initWithString:
                        [[BalsamiqReaderConfig instance] getBalsamiqFilePath:fileName]];
		
		// 3 生成各个控件
		for (BalsamiqControlData *data in balsamiqData)
		{
			NSString *controlType = [[data.attributeDic objectForKey:@"controlTypeID"]
									 substringFromIndex:[@"com.balsamiq.mockups::" length]];
			
			NSString* methodName = [NSString stringWithFormat:@"create%@:", controlType];
			SEL creatorSel = sel_registerName([methodName UTF8String]);
			
			if ([self respondsToSelector:creatorSel])
			{
                [self performSelector:creatorSel withObject:data];
			}
		}
		
		// 4 初始化Radio控件
		for (RadioManager *radioManager in [groupAndRadioDic allValues])
		{
			[radioManager selectFirstItem];
		}
        
        // *** 打印各个控件信息
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
    return [nameAndControlDic objectForKey:name];
}

- (NSString *)getSelectedRadioByGroup:(NSString *)group
{
    RadioManager *radioManager = [groupAndRadioDic objectForKey:group];
    return radioManager.selectedItemInfo;
}

@end
