//
//  JavaMethod.m
//  cocotest
//
//  Created by xiezhenghai on 10-11-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JavaMethod.h"


@implementation NSInputStream(ND)

- (int)readByte
{
	static unsigned char byteBuf[1] = {0x00};
	int readLen = [self read:byteBuf maxLength:1];
	if (readLen) 
	{
		return byteBuf[0];
	}
	else 
	{
		NDAsssert(0);
		return 0;
		//@throw [NSException exceptionWithName:@"NSInputStream" reason:@"read from stream error" userInfo:nil];
	}
}

- (int)readShort
{
	static unsigned char shortBuf[2] = {0x00};
	int readLen = [self read:shortBuf maxLength:2];
	if (readLen) 
	{
		return (short)((shortBuf[0] << 8) + shortBuf[1]);
	}
	else 
	{
		NDAsssert(0);
		return 0;
		//@throw [NSException exceptionWithName:@"NSInputStream" reason:@"read from stream error" userInfo:nil];
	}
}

- (int)readInt
{
	static unsigned char intBuf[4] = {0x00};
	int readLen = [self read:intBuf maxLength:4];
	if (readLen) 
	{
		return ((intBuf[0] << 24) + (intBuf[1] << 16) + (intBuf[2] << 8) + intBuf[3]);
	}
	else 
	{
		NDAsssert(0);
		return 0;
		//@throw [NSException exceptionWithName:@"NSInputStream" reason:@"read from stream error" userInfo:nil];
	}
}

- (NSString *)readUTF8String
{
	NSString* str = @"";
	int strLen = ([self readByte] << 8) + [self readByte];	
	if (strLen) 
	{
		unsigned char *buffer = (unsigned char *)malloc(sizeof(unsigned char) * strLen + 1);
		memset(buffer, 0x00, strLen + 1);
		
		[self read:buffer maxLength:strLen];
		
		str = [NSString stringWithUTF8String:(const char*)buffer];
		
		free(buffer);
	}
	
	return str;
}

- (NSString *)readUTF8StringNoExcept
{
	unsigned char byteBufHight, byteBufLow;
	int readLen = [self read:&byteBufHight maxLength:1];
	if (!readLen) 
	{
		return @"";
	}
	
	readLen = [self read:&byteBufLow maxLength:1];
	if (!readLen) 
	{
		return @"";
	}
	
	int strLen = ((int)byteBufHight << 8) + byteBufLow;
	
	unsigned char *buffer = (unsigned char *)malloc(sizeof(unsigned char) * strLen + 1);
	memset(buffer, 0x00, strLen + 1);
	
	readLen = [self read:buffer maxLength:strLen];
	NSString* str = @"";
	if (readLen) 
	{
		str = [NSString stringWithUTF8String:(const char*)buffer];
	}
	
	free(buffer);
	return str;
}

@end
