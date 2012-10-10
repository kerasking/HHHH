//
//  JavaMethod.h
//  cocotest
//
//  Created by xiezhenghai on 10-11-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _JAVA_METHOD_H_
#define _JAVA_METHOD_H_

#include <string>

//以下所有的方法时java上特有的，为了移植的方便，重新构造类似的方法

//输入流用于读取二进制文件，扩展于系统自待的输入流
//调用之前请先打开流－－open
//调用完成之后请关闭流
struct FileOp
{
	//读取一字节内容
	int readByte(FILE* f);
	//读取两字节内容
	int readShort(FILE* f);
	//读取四字节内容
	int readInt(FILE* f);
	//读取utf8字符串
	std::string readUTF8String(FILE* f);
	//读取utf8字符串
	std::string readUTF8StringNoExcept(FILE* f);
};

#endif
