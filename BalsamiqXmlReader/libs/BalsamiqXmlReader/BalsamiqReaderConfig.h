//
//  BalsamiqReaderConfig.h
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 11-11-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BalsamiqReaderConfig : NSObject
{
    NSString *balsamiqFontName;
    ccColor3B buttonNormalTextColor;
    ccColor3B buttonSelectTextColor;
    ccColor3B textInputColor;
    NSString *balsamiqRootDir;
    NSString *loadingBarPic;
    
    NSDictionary *bmmlAndPathDic;
}

@property (nonatomic, copy) NSString *balsamiqFontName;
@property ccColor3B buttonNormalTextColor;
@property ccColor3B buttonSelectTextColor;
@property ccColor3B textInputColor;
@property (nonatomic, copy) NSString *balsamiqRootDir;
@property (nonatomic, copy) NSString *loadingBarPic;

+ (BalsamiqReaderConfig *)instance;

/*!
    @名    称：setBalsamiqConfigWithPropertyListFile
    @描    述：在默认的plist文件中，查找指定的字典对象，进行配置
    @参    数：configKey
    @返 回 值：
    @备    注：
*/
- (void)loadBalsamiqConfigWithPropertyListFile:(NSString *)configKey;

/*!
    @名    称：setBalsamiqRootDir
    @描    述：设置存放目录
    @参    数：目录在mainBunddle中的相对地址
    @返 回 值：
    @备    注：使用本类时，必须设置一个界面文件的存放目录
*/
- (void)setBalsamiqRootDir:(NSString *)rootDir;

/*!
    @名    称：loadBalsamiqConfig
    @描    述：使用一个字典对象，进行配置
    @参    数：configDic
    @返 回 值：
    @备    注：
*/
- (void)loadBalsamiqConfig:(NSDictionary *)configDic;

/*!
    @名    称：getBalsamiqFilePath
    @描    述：根据文件名，获取文件路径
    @参    数：fileName
    @返 回 值：
    @备    注：
*/
- (NSString *)getBalsamiqFilePath:(NSString *)fileName;

@end
