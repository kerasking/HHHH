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
#include <fstream>

#include <boost/config/warning_disable.hpp>
#include <boost/noncopyable.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/program_options.hpp>
#include <boost/assign.hpp>
#include <boost/typeof/typeof.hpp>
#include <boost/progress.hpp>
#include <boost/crc.hpp>

using namespace std;
using namespace boost;
using namespace boost::assign;
using namespace boost::property_tree;
using namespace boost::filesystem;
using namespace boost::program_options;

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