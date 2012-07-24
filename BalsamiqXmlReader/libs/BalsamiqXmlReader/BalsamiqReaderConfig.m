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
#define KEY_BALSAMIQ_BTN_DISABLE_TEXT_COLOR @"ButtonDisableTextColor"

#define KEY_BALSAMIQ_BTN_SELECT_IMAGE_COLOR @"ButtonSelectImageColor"
#define KEY_BALSAMIQ_BTN_DISABLE_IMAGE_COLOR @"ButtonDisableImageColor"
#define KEY_BALSAMIQ_INPUT_TEXT_COLOR @"TextInputColor"

ccColor3B ccColor3BFromNSString(NSString *str, ccColor3B defaultColor);

@implementation BalsamiqReaderConfig

@synthesize rootDir, balsamiqFontName;
@synthesize buttonNormalTextColor, buttonSelectTextColor, buttonDisableTextColor;
@synthesize buttonSelectImageColor, buttonDisableImageColor, textInputColor;

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
        self.rootDir = @"";
        self.balsamiqFontName = @"Arial";
        
        self.buttonNormalTextColor = (ccColor3B){255, 255, 255};
        self.buttonSelectTextColor = (ccColor3B){200, 200, 200};
        self.buttonDisableTextColor = (ccColor3B){255, 0, 0};
        
        self.buttonSelectImageColor = (ccColor3B){200, 200, 200};
        self.buttonDisableImageColor = (ccColor3B){150, 150, 150}; 
        
        self.textInputColor = (ccColor3B){200, 200, 200};
	}
	return self;
}

- (void) dealloc
{
    [bmmlAndPathDic release];
    self.rootDir = nil;
    self.balsamiqFontName = nil;
    
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
	
	filePath = [rootDir stringByAppendingPathComponent:filePath];
	
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

- (void)setBalsamiqRootDir:(NSString *)dir
{
	if (bmmlAndPathDic != nil)
	{
        [bmmlAndPathDic release];
        bmmlAndPathDic = nil;
    }
    
    self.rootDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dir];
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.rootDir isDirectory:&isDir] == NO)
    {
        NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is nil", NSStringFromSelector(_cmd), dir);
    }
    else if (isDir == NO)
    {
        NSAssert(0, @"CCBalsamiqLayer#%@ rootDir = %@ is not dir", NSStringFromSelector(_cmd), dir);
    }
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (NSString *fileName in [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.rootDir error:nil])
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
    
    buttonNormalTextColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_NORMAL_TEXT_COLOR],
                                                  buttonNormalTextColor);
    buttonSelectTextColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_SELECT_TEXT_COLOR],
                                                  buttonSelectTextColor);
    buttonDisableTextColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_DISABLE_TEXT_COLOR],
                                                   buttonDisableTextColor);
    
    buttonSelectImageColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_SELECT_IMAGE_COLOR],
                                                   buttonSelectImageColor);
    buttonDisableImageColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_BTN_DISABLE_IMAGE_COLOR],
                                                    buttonDisableImageColor);
	
    textInputColor = ccColor3BFromNSString([configDic objectForKey:KEY_BALSAMIQ_INPUT_TEXT_COLOR],
                                           textInputColor);
}

@end

ccColor3B ccColor3BFromNSString(NSString *str, ccColor3B defaultColor)
{
	if (str.length == 0)
	{
		return defaultColor;
	}
	
	NSArray *sep = [[str stringByReplacingOccurrencesOfString:@" " withString:@""]
					componentsSeparatedByString:@","];
	if (sep.count != 3)
	{
		return defaultColor;
	}
	
	ccColor3B color = 
	{
		[[sep objectAtIndex:0] intValue],
		[[sep objectAtIndex:1] intValue],
		[[sep objectAtIndex:2] intValue],
	};
	
	return color;
}
