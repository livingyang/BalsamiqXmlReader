//
//  CCBalsamiqLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RadioManager.h"

@interface CCBalsamiqLayer : CCLayer
{
    /*!
        @名    称：nameAndControlDic
        @描    述：保存控件与其名字的字典
        @备    注：
    */
    NSMutableDictionary *nameAndControlDic;
    
	/*!
		@名    称：uiViewArray
		@描    述：保存webView控件的数组
		@备    注：
	*/
	NSMutableArray *uiViewArray;
	
	/*!
		@名    称：radioArray
		@描    述：保存radio控件的数组,key = NSString, value = RadioManager
		@备    注：例，customID = radio_test_btn1，则key = "test"
	*/
	NSMutableDictionary *groupAndRadioDic;
}

@property (nonatomic, readonly) NSMutableDictionary *nameAndControlDic;
@property (nonatomic, readonly) NSMutableArray *uiViewArray;

// 带有事件的控件，如button，toggle，其事件的处理者为eventHandle

- (id)initWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle;

+ (id)layerWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle;

- (id)getControlByName:(NSString *)name;

- (NSString *)getSelectedRadioByGroup:(NSString *)group;

@end

// #1 CCBalsamiqLayer所创建的UITextField，会在内部进行释放，无须外部释放

/*
 #2 若需要创建Toggle(CheckBox)，需要满足以下几点
 1 事件处理者需实现方法： (void)toggleCallBack:(id)sender
 2 Balsamiq文件中控件的CustomID，含有"toggle_"前缀
 3 Balsamiq文件中控件的图片名称，含有@"-1"字符串，若toggle有多个图片，
 依次命名为"-2", "-3"等
*/