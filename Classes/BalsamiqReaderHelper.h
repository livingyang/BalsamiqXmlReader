/*
 *  BalsamiqReaderHelper.h
 *  BalsamiqXmlReader
 *
 *  Created by lee living on 11-8-15.
 *  Copyright 2011 LieHuo Tech. All rights reserved.
 *
 */

#ifndef BALSAMIQREADERHELPER_H
#define BALSAMIQREADERHELPER_H

static inline
NSArray *getBalsamiqData(NSString *fileName)
{
	NSString *xmlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
	
	return [BalsamiqControlData parseData:[NSString stringWithContentsOfFile:xmlPath
																	encoding:NSUTF8StringEncoding
																	   error:nil]];
}

#endif //BALSAMIQREADERHELPER_H