//
//  JavaMethod.h
//  cocotest
//
//  Created by xiezhenghai on 10-11-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//以下所有的方法时java上特有的，为了移植的方便，重新构造类似的方法

//输入流用于读取二进制文件，扩展于系统自待的输入流
//调用之前请先打开流－－open
//调用完成之后请关闭流
@interface NSInputStream(ND)
//读取一字节内容
- (int)readByte;
//读取两字节内容
- (int)readShort;
//读取四字节内容
- (int)readInt;
//读取utf8字符串
- (NSString *)readUTF8String;
//读取utf8字符串
- (NSString *)readUTF8StringNoExcept;
@end
