// stdafx.h : 标准系统包含文件的包含文件，
// 或是经常使用但不常更改的
// 特定于项目的包含文件
//

#pragma once

#include "targetver.h"

#include <stdio.h>
#include <tchar.h>

#include <tinyxml.h>

#include <vector>
#include <string>

using namespace std;

#define SAFE_DELETE(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete pObject;\
		pObject = 0;\
	}\
} while (false)

#define SAFE_DELETE_ARRAY(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete [] pObject;\
		pObject = 0;\
	}\
} while (false)

#define SAFE_RELEASE(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		pObject->release();\
		pObject = 0;\
	}\
} while (false)