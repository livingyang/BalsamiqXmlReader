//
//  CCBalsamiqLayer.h
//  BalsamiqXmlReader
//
//  Created by lee living on 11-7-21.
//  Copyright 2011 LieHuo Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "BalsamiqXmlDef.h"

@interface CCBalsamiqLayer : CCLayer

/*!
    @名    称：setBalsamiqRootDir
    @描    述：设置存放目录
    @参    数：目录在mainBunddle中的相对地址
    @返 回 值：
    @备    注：使用本类时，必须设置一个界面文件的存放目录
*/
+ (void)setBalsamiqRootDir:(NSString *)rootDir;

// 带有事件的控件，如button，toggle，其事件的处理者为eventHandle
// 控件创建完毕后，createdHandle将收到创建完毕的回调

- (id)initWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle createdHandle:(id)createdHandle;

+ (id)layerWithBalsamiqFile:(NSString *)fileName eventHandle:(id)eventHandle createdHandle:(id)createdHandle;

@end

// #1 CCBalsamiqLayer所创建的UITextField，会在内部进行释放，无须外部释放

/*
 #2 若需要创建Toggle(CheckBox)，需要满足以下几点
 1 事件处理者需实现方法： (void)toggleCallBack:(id)sender
 2 Balsamiq文件中控件的CustomID，含有"toggle_"前缀
 3 Balsamiq文件中控件的图片名称，含有@"-1"字符串，若toggle有多个图片，
 依次命名为"-2", "-3"等
*/