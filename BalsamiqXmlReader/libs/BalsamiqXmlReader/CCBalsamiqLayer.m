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
#import "CCLabelWithTextField.h"
#import "CCTableLayer.h"
#import "BalsamiqFileParser.h"
#import "BalsamiqReaderConfig.h"

#define IMAGE_PREFIX @"image_"
#define RADIO_PREFIX @"radio_"
#define BAR_PREFIX @"bar_"
#define TOGGLE_PREFIX @"toggle_"
#define TAB_PREFIX @"tab_"

@implementation CCBalsamiqLayer : CCLayer

@synthesize bmmlFileName;

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

- (NSString *)bmmlFilePath
{
    return [[BalsamiqReaderConfig instance] getBalsamiqFilePath:self.bmmlFileName];
}

//格式字符串的特殊字符替换表
- (NSString *)getDecodeText:(NSString *)text
{
    NSString *convertedString = [[text stringByReplacingOccurrencesOfString:@"%u" withString:@"\\u"] mutableCopy];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return [convertedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
	CCTextAlignment textAlign = kCCTextAlignmentLeft;
	if ([align isEqualToString:@"right"])
	{
		textAlign = kCCTextAlignmentRight;
	}
	else if ([align isEqualToString:@"center"])
	{
		textAlign = kCCTextAlignmentCenter;
	}
	
	return textAlign;
}

- (CGPoint)getAnchorPointWithTextAlignment:(CCTextAlignment)align
{
    switch (align)
    {
        case kCCTextAlignmentLeft:
        {
            return ccp(0.0f, 0.5f);
        }break;
        case kCCTextAlignmentCenter:
        {
            return ccp(0.5f, 0.5f);
        }break;
        case kCCTextAlignmentRight:
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
    return [[self.bmmlFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:src];
}

- (NSString *)getRadioGroup:(NSString *)radioItemName
{
    NSArray *radioParamArray = [radioItemName componentsSeparatedByString:@"_"];
    
    if (radioParamArray.count == 3)
    {
        return [radioParamArray objectAtIndex:1];
    }
    
    return nil;
}

- (id)createButton:(BalsamiqControlData *)data
			target:(id)target
			   sel:(SEL)sel
{
	NSString *picPath = [self getPicPath:[data.propertyDic objectForKey:@"src"]];
    NSString* pressPicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-press"];
	NSString* disablePicPath = [picPath stringByReplacingOccurrencesOfString:@"-normal" withString:@"-disable"];
	
    CCSprite *normalSprite = [CCSprite spriteWithFile:picPath];
    NSAssert(normalSprite != nil, @"CCBalsamiqLayer#createButton normalSprite is nil");
    CCSprite *selectSprite = [CCSprite spriteWithFile:pressPicPath];
    CCSprite *disableSprite = [CCSprite spriteWithFile:disablePicPath];
    
    if ([pressPicPath isEqualToString:picPath])
    {
        selectSprite.color = [BalsamiqReaderConfig instance].buttonSelectImageColor;
    }
    
    if ([disablePicPath isEqualToString:picPath])
    {
        disableSprite.color = [BalsamiqReaderConfig instance].buttonDisableImageColor;
    }
    
	CCMenuItemButton *item = [CCMenuItemButton itemWithNormalSprite:normalSprite
                                                     selectedSprite:selectSprite
                                                     disabledSprite:disableSprite
                                                             target:target
                                                           selector:sel];
    
	
	CGSize itemSize = [self getBalsamiqControlSize:data];
	if (CGSizeEqualToSize(item.contentSize, itemSize) == NO)
	{
		item.scaleX = itemSize.width / item.contentSize.width;
		item.scaleY = itemSize.height / item.contentSize.height;
	}
	item.position = [self getMidPosition:data];
	
    CCMenu *menu = [CCTableMenu menuWithItems:item, nil];
    menu.anchorPoint = CGPointZero;
    menu.position = CGPointZero;
    [self addChild:menu z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
	//若有文本，则需要生成标签
	NSString *text = [data.propertyDic objectForKey:@"text"];
	if (text != nil)
	{
		[item initLabel:[self getDecodeText:text] 
			   fontName:[BalsamiqReaderConfig instance].balsamiqFontName
			   fontSize:[self getBalsamiqControlTextSize:data]
			normalColor:[BalsamiqReaderConfig instance].buttonNormalTextColor 
			selectColor:[BalsamiqReaderConfig instance].buttonSelectTextColor
		   disableColor:[BalsamiqReaderConfig instance].buttonDisableTextColor];
		
		item.label.scaleX = 1 / item.scaleX;
		item.label.scaleY = 1 / item.scaleY;
	}
	
	return item;
}

- (id)createToggle:(BalsamiqControlData *)data
			target:(id)target
			   sel:(SEL)sel
{
	NSString *picPath = [self getPicPath:[data.propertyDic objectForKey:@"src"]];
    
    NSString* checkedPicPath = [picPath stringByReplacingOccurrencesOfString:@"-unchecked" withString:@"-checked"];
	
    CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:target
                                                       selector:sel
                                                          items:
                                [CCMenuItemImage itemWithNormalImage:picPath selectedImage:picPath],
                                [CCMenuItemImage itemWithNormalImage:checkedPicPath selectedImage:checkedPicPath],
                                nil];
    
	CGSize itemSize = [self getBalsamiqControlSize:data];
	if (CGSizeEqualToSize(toggle.contentSize, itemSize) == NO)
	{
		toggle.scaleX = itemSize.width / toggle.contentSize.width;
		toggle.scaleY = itemSize.height / toggle.contentSize.height;
	}
	toggle.position = [self getMidPosition:data];
	
    CCMenu *menu = [CCTableMenu menuWithItems:toggle, nil];
    menu.anchorPoint = CGPointZero;
    menu.position = CGPointZero;
    [self addChild:menu z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
	return toggle;
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
            
            SEL itemClickSel = NSSelectorFromString([NSString stringWithFormat:@"onSelect_%@:", chkManager.selectedItemInfo]);
            if ([eventHandle_ respondsToSelector:itemClickSel])
            {
                [eventHandle_ performSelector:itemClickSel
                                   withObject:sender];
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
    
    if ([nameAndControlDic objectForKey:name] != nil)
    {
        CCLOG(@"CCBalsamiqLayer#addControl duplicate name = %@, bmml file = %@",
              name,
              self.bmmlFileName);
    }
    
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

- (RadioManager *)getOrCreateRadioManager:(NSString *)radioGroup
{
    if (radioGroup.length == 0)
    {
        CCLOG(@"CCBalsamiqLayer#getOrCreateRadioManager radioGroup is invalid!");
        return nil;
    }
    
    RadioManager *chkManager = [groupAndRadioDic objectForKey:radioGroup];
    if (chkManager == nil)
    {
        chkManager = [[[RadioManager alloc] init] autorelease];
        [groupAndRadioDic setValue:chkManager forKey:radioGroup];
    }
    
    return chkManager;
}

- (void)checkAndSetTab:(NSString *)tabName node:(CCNode *)node
{
    if ([tabName hasPrefix:TAB_PREFIX])
    {
        RadioManager *tabRadioManager = [self getOrCreateRadioManager:
                                         [TAB_PREFIX stringByReplacingOccurrencesOfString:@"_" withString:@""]];
        [tabRadioManager setItemName:[RADIO_PREFIX stringByAppendingString:tabName] withTab:node];
    }
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
        NSString *radioGroup = [self getRadioGroup:customID];
        NSAssert(radioGroup.length > 0, @"CCBalsamiqLayer#createImage radio param error");
		
		id button = [self createButton:data
								target:self
								   sel:@selector(onRadioItemClick:)];
		
		[[self getOrCreateRadioManager:radioGroup] addItem:button withInfo:customID];
	}
	else if ([customID hasPrefix:TOGGLE_PREFIX])
    {
        NSString *methodName = [NSString stringWithFormat:@"onClick_%@:", customID];
        
		SEL eventSel = NSSelectorFromString(methodName);
		
        if ([eventHandle_ respondsToSelector:eventSel])
        {
            [self setControl:[self createToggle:data
                                         target:eventHandle_
                                            sel:eventSel]
                    withName:customID];
        }
        else
        {
            [self setControl:[self createToggle:data
                                         target:self
                                            sel:@selector(onNoneHandleButtonClick:)]
                    withName:customID];
        }
    }
	else if ([customID hasPrefix:BAR_PREFIX])
    {
		//创建Bar控件
		CCProgressTimer *bar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:picPath]];
        bar.type = kCCProgressTimerTypeBar;
		bar.percentage = 100;
        
		CGSize itemSize = [self getBalsamiqControlSize:data];
		if (CGSizeEqualToSize(bar.contentSize, itemSize) == NO)
		{
			bar.scaleX = itemSize.width / bar.contentSize.width;
			bar.scaleY = itemSize.height / bar.contentSize.height;
		}
		bar.position = [self getMidPosition:data];
		[self addChild:bar z:zOrder];
		
        [self setControl:bar withName:customID];
    }
	else
	{
		//生成事件名称
		NSString* methodName = [NSString stringWithFormat:@"on%@Click:", customID];
		SEL eventSel = NSSelectorFromString(methodName);
		
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
    @名    称：createSubTitle
    @描    述：创建文本输入框
    @参    数：data
    @参    数：createInfo
    @返 回 值：
    @备    注：
*/
- (void)createSubTitle:(BalsamiqControlData *)data
{
    CCLabelWithTextField *label = [CCLabelWithTextField labelWithString:[self getDecodeText:[data.propertyDic objectForKey:@"text"]]
                                                               fontName:[BalsamiqReaderConfig instance].balsamiqFontName
                                                               fontSize:[self getBalsamiqControlTextSize:data]
                                                             dimensions:[self getBalsamiqControlSize:data]
                                                              hAlignment:[self getBalsamiqControlAlign:data]];
    
    label.position = [self convertControlPosition:[self getBalsamiqControlPosition:data]
                                         nodeSize:[self getBalsamiqControlSize:data]
                                  withAnchorPoint:label.anchorPoint];
	
	label.color = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	
	[self addChild:label z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
    [self setControl:label withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createTextArea:(BalsamiqControlData *)data
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:[self getDecodeText:[data.propertyDic objectForKey:@"text"]]
                                           fontName:[BalsamiqReaderConfig instance].balsamiqFontName
                                           fontSize:[self getBalsamiqControlTextSize:data]
                                         dimensions:[self getBalsamiqControlSize:data]
                                          hAlignment:[self getBalsamiqControlAlign:data]];
    
    label.anchorPoint = [self getAnchorPointWithTextAlignment:[self getBalsamiqControlAlign:data]];
    label.position = [self convertControlPosition:[self getBalsamiqControlPosition:data]
                                         nodeSize:[self getBalsamiqControlSize:data]
                                  withAnchorPoint:label.anchorPoint];
	
	label.color = [self getColor:[[data.propertyDic objectForKey:@"color"] intValue]];
	
	[self addChild:label z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
	
    [self setControl:label withName:[data.propertyDic objectForKey:@"customID"]];
}

- (void)createCanvas:(BalsamiqControlData *)data
{
    CCTableLayer *tableLayer = [CCTableLayer node];
    tableLayer.contentSize = [self getBalsamiqControlSize:data];
    tableLayer.anchorPoint = ccp(0.5f, 0.5f);
    tableLayer.position = [self getMidPosition:data];
    
    [self addChild:tableLayer z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
    [self setControl:tableLayer withName:[data.propertyDic objectForKey:@"customID"]];
    
    [self checkAndSetTab:[data.propertyDic objectForKey:@"customID"] node:tableLayer];
}

- (void)createFieldSet:(BalsamiqControlData *)data
{
    NSString *fileName = [self getDecodeText:[data.propertyDic objectForKey:@"text"]];
    
    CCBalsamiqLayer *layer = [CCBalsamiqLayer layerWithBalsamiqFile:fileName eventHandle:eventHandle_];
    layer.position = [self convertControlPosition:[self getBalsamiqControlPosition:data]
                                         nodeSize:[self getBalsamiqControlSize:data]
                                  withAnchorPoint:ccp(0, 0)];
    [self addChild:layer z:[[data.attributeDic objectForKey:@"zOrder"] intValue]];
    [self setControl:layer withName:[data.propertyDic objectForKey:@"customID"]];
    
    [self checkAndSetTab:[data.propertyDic objectForKey:@"customID"] node:layer];
    
    if (CGSizeEqualToSize(layer.contentSize, [self getBalsamiqControlSize:data]) == false)
    {
        CCLOG(@"CCBalsamiqLayer#createFieldSet link layer contentSize is not equal, link layer = %@, id = %@",
              fileName,
              [data.propertyDic objectForKey:@"customID"]);
    }
}

////////////////////////////////////////////////////////
#pragma mark 继承函数
////////////////////////////////////////////////////////


- (void) dealloc
{
    self.bmmlFileName = nil;
    
    [nameAndControlDic release];
	[groupAndRadioDic release];
    
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
		groupAndRadioDic = [[NSMutableDictionary alloc] init];
        eventHandle_ = eventHandle;
        originControlPosition = ccp(0, 0);
		
		self.ignoreAnchorPointForPosition = NO;
		self.anchorPoint = ccp(0, 0);
		
		NSMutableArray *balsamiqData = [[BalsamiqFileParser instance] getControlsData:
                                        [[BalsamiqReaderConfig instance] getBalsamiqFilePath:fileName]];
		
        if (balsamiqData == nil)
		{
			NSLog(@"CCBalsamiqLayer#%@ fileName = %@ is nil", NSStringFromSelector(_cmd), fileName);
			return nil;
		}
		
        self.bmmlFileName = fileName;
        
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
		
		// 2 生成各个控件
		for (BalsamiqControlData *data in balsamiqData)
		{
			NSString *controlType = [[data.attributeDic objectForKey:@"controlTypeID"]
									 substringFromIndex:[@"com.balsamiq.mockups::" length]];
			
			NSString* methodName = [NSString stringWithFormat:@"create%@:", controlType];
			SEL creatorSel = NSSelectorFromString(methodName);
			
			if ([self respondsToSelector:creatorSel])
			{
                [self performSelector:creatorSel withObject:data];
			}
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

- (RadioManager *)getRadioManagerByGroup:(NSString *)group
{
    RadioManager *radioManager = [groupAndRadioDic objectForKey:group];
    return radioManager;
}

- (void)selectRadioItem:(NSString *)selectItemName
{
    [[groupAndRadioDic objectForKey:[self getRadioGroup:selectItemName]]
     selectItemByName:selectItemName];
}

+ (CCBalsamiqLayer *)getBalsamiqLayerFromChild:(id)node
{
    while ([node isKindOfClass:[CCBalsamiqLayer class]] == NO)
    {
        if ([node parent] == nil)
        {
            return nil;
        }
        
        node = [node parent];
    }
    
    return node;
}

@end
