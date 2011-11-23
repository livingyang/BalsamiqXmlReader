//
//  BalsamiqReaderConfig.m
//  BalsamiqXmlReader
//
//  Created by 青宝 中 on 11-11-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BalsamiqReaderConfig.h"

#define KEY_BALSAMIQ_ROOT_DIR @"RootDir"
#define KEY_BALSAMIQ_FONT_NAME @"FontName"
#define KEY_BALSAMIQ_BTN_NORMAL_TEXT_COLOR @"ButtonNormalTextColor"
#define KEY_BALSAMIQ_BTN_SELECT_TEXT_COLOR @"ButtonSelectTextColor"
#define KEY_BALSAMIQ_INPUT_TEXT_COLOR @"TextInputColor"

ccColor3B ccColor3BFromNSString(NSString *str);

@implementation BalsamiqReaderConfig

@synthesize balsamiqFontName, buttonNormalTextColor, buttonSelectTextColor, textInputColor, balsamiqRootDir, loadingBarPic;

+ (BalsamiqReaderConfig *)instance
{
    static BalsamiqReaderConfig *config = nil;
    if (config == nil)
    {
        config = [[BalsamiqReaderConfig alloc] init];
    }
    
    return config;
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
        buttonNormalTextColor = (ccColor3B){255, 255, 255};
        buttonSelectTextColor = (ccColor3B){200, 200, 200};
        textInputColor = (ccColor3B){200, 200, 200};
        
        balsamiqFontName = @"Arial";
        balsamiqRootDir = @"";
        loadingBarPic = @"loading-bar.png";
	}
	return self;
}

- (void) dealloc
{
    [bmmlAndPathDic release];
    
	[super dealloc];
}

- (NSString *)getBalsamiqFilePath:(NSString *)fileName
{
	if (bmmlAndPathDic == nil)
	{
		NSLog(@"CCBalsamiqLayer#%@ bmmlAndPathDic is nil", NSStringFromSelector(_cmd));
		return nil;
	}
	NSString *filePath = [bmmlAndPathDic objectForKey:fileName];
	if (filePath == nil)
	{
		return nil;
	}
	
	filePath = [balsamiqRootDir stringByAppendingPathComponent:filePath];
	
	return filePath;
}

#pragma mark -
#pragma mark 配置读取函数

- (void)loadBalsamiqConfigWithPropertyListFile:(NSString *)configKey
{
	NSDictionary *dic = [[NSBundle mainBundle] objectForInfoDictionaryKey:configKey];
    
    NSAssert(dic != nil, @"CCBalsamiqLayer#setBalsamiqConfigWithPropertyListFile: config = %@ is nil", configKey);
	
	[self loadBalsamiqConfig:dic];
}

- (void)setBalsamiqRootDir:(NSString *)rootDir
{
	if (bmmlAndPathDic != nil)
	{
        [bmmlAndPathDic release];
        bmmlAndPathDic = nil;
    }
    
    balsamiqRootDir = [[NSString alloc] initWithString:[[[NSBundle mainBundle] bundlePath]
                                                        stringByAppendingPathComponent:rootDir]];
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:balsamiqRootDir isDirectory:&isDir] == NO)
    {
        NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is nil", NSStringFromSelector(_cmd), rootDir);
    }
    else if (isDir == NO)
    {
        NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is not dir", NSStringFromSelector(_cmd), rootDir);
    }
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (NSString *fileName in [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:balsamiqRootDir error:nil])
    {
        if ([[fileName pathExtension] isEqualToString:@"bmml"])
        {
            NSAssert([dic objectForKey:[fileName lastPathComponent]] == nil,
                     @"CCBalsamiqLayer#%@ fileName = %@ is duplicate with %@",
                     NSStringFromSelector(_cmd),
                     fileName,
                     [dic objectForKey:[fileName lastPathComponent]]);
            
            [dic setValue:fileName forKey:[fileName lastPathComponent]];
        }
    }
    
    bmmlAndPathDic = dic;
    CCLOG(@"dic = %@", dic);
}

- (void)loadBalsamiqConfig:(NSDictionary *)configDic
{
	if ([configDic objectForKey:KEY_BALSAMIQ_ROOT_DIR] != nil)
	{
		[self setBalsamiqRootDir:[configDic objectForKey:KEY_BALSAMIQ_ROOT_DIR]];
	}
	
	if ([configDic objectForKey:KEY_BALSAMIQ_FONT_NAME] != nil
		&& [configDic objectForKey:KEY_BALSAMIQ_FONT_NAME] != balsamiqFontName)
	{
		if (balsamiqFontName != nil)
		{
			[balsamiqFontName release];
		}
		
		balsamiqFontName = [configDic objectForKey:KEY_BALSAMIQ_FONT_NAME];
		[balsamiqFontName retain];
	}
	
	if ([configDic objectForKey:KEY_BALSAMIQ_BTN_NORMAL_TEXT_COLOR] != nil)
	{
		buttonNormalTextColor =
		ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_NORMAL_TEXT_COLOR]);
	}
	
	if ([configDic objectForKey:KEY_BALSAMIQ_BTN_SELECT_TEXT_COLOR] != nil)
	{
		buttonSelectTextColor =
		ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_SELECT_TEXT_COLOR]);
	}
	
	if ([configDic objectForKey:KEY_BALSAMIQ_INPUT_TEXT_COLOR] != nil)
	{
		textInputColor =
		ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_INPUT_TEXT_COLOR]);
	}
}

@end

ccColor3B ccColor3BFromNSString(NSString *str)
{
	if (str == nil)
	{
		return ccWHITE;
	}
	
	NSArray *sep = [[str stringByReplacingOccurrencesOfString:@" " withString:@""]
					componentsSeparatedByString:@","];
	if (sep.count != 3)
	{
		return ccWHITE;
	}
	
	ccColor3B color = 
	{
		[[sep objectAtIndex:0] intValue],
		[[sep objectAtIndex:1] intValue],
		[[sep objectAtIndex:2] intValue],
	};
	
	return color;
}
