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
	int readByte(FILE* f);

	int readShort(FILE* f);

	int readInt(FILE* f);

	std::string readUTF8String(FILE* f);

	std::string readUTF8StringNoExcept(FILE* f);
};

#endif
