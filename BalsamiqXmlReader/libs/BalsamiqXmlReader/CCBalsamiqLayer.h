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
    
	/*!
        @名    称：eventHandle_
        @描    述：事件处理着，继承了CCBalsamiqLayerDelegate接口
        @备    注：
    */
    id eventHandle_;
    
	/*!
        @名    称：controlMenu
        @描    述：所有按钮全部保存在这个menu中
        @备    注：
    */
    CCMenu *controlMenu;
    
	/*!
        @名    称：bmmlFilePath
        @描    述：当前对象所对应的文件路径
        @备    注：
    */
    NSString *bmmlFilePath;
    
	/*!
        @名    称：originControlPosition
        @描    述：modalScreen的初始位置，用于定位窗体的初始位置
        @备    注：
    */
    CGPoint originControlPosition;
}

@property (nonatomic, readonly) NSString *bmmlFilePath;
@property (nonatomic, readonly) NSMutableArray *uiViewArray;

// 带有事件的控件，如button，toggle，其事件的处理者为eventHandle

- (id)initWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle;

+ (id)layerWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle;

- (id)getControlByName:(NSString *)name;


/*!
    @名    称：getSelectedRadioByGroup
    @描    述：get radio select item name by radio group
    @备    注：单击单选框时，对应的调用方法为：- (void)on[group]RadioSelected:(NSString *)itemName
    @备    注：新增单个单选框的调用，方法为：- (void)onSelect_[itemName]:(id)sender
*/
- (NSString *)getSelectedRadioByGroup:(NSString *)group;

@end
