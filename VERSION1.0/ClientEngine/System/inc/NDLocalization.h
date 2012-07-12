/*
 *  NDLocalization.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

// 本地化接口
// 1.NDNSString, 参数NSString字符串, 访问范围当前文件(key仅限当前文件使用)
// 2.NDCString, 参数C字符串, 访问范围当前文件(key仅限当前文件使用)
// 3.NDCommonNSString, 参数NSString字符串, 访问范围所有文件(即所有文件共用key,但不会与访问范围为当前文件的产生冲突)
// 4.NDCommonCString, 参数C字符串, 访问范围所有文件(即所有文件共用key,但不会与访问范围为当前文件的产生冲突)
// 用法:
// 1.NDNSString(@"example");
// 2.NDCString("example");
// 3.NDCommonNSString(@"example");
// 4.NDCommonCString("example");
#ifndef _ND_LOCALIZATION_H_ZJH_
#define _ND_LOCALIZATION_H_ZJH_

#include "NDLocalXmlString.h"

// inline const char* __NDLOCAL_INNER_STRING(NSString* nsKeyName)
// {
// 	//return [NSLocalizedStringWithDefaultValue(nsKeyName, @"lyol", [NSBundle mainBundle], nsKeyName, NULL) UTF8String];
// 	return [NDLocalXmlString::GetSingleton().GetString(nsKeyName) UTF8String];
// }

inline const char* __NDLOCAL_INNER_C_STRING(const char* szModuleName, const char* szKeyName)
{
	//return [NSLocalizedStringWithDefaultValue(nsKeyName, @"lyol", [NSBundle mainBundle], nsKeyName, NULL) UTF8String];
	if (!szModuleName || !szKeyName)
	{
		return "";
	}
	
	std::string str		= szModuleName;
	str					+= szKeyName; 
	return NDLocalXmlString::GetSingleton().GetCString(str.c_str()).c_str();
}

#define _NDLOCAL_INNER_NS_STRING( NSKeyFileName, NSKeyName) \
__NDLOCAL_INNER_STRING("%s_%s", NSKeyFileName, NSKeyName])

#define _NDLOCAL_INNER_CString_STRING( NSKeyFileName, cStringKeyName) \
__NDLOCAL_INNER_STRING("%s_%s", NSKeyFileName, cStringKeyName])

#pragma mark 以文件名+"_"+KeyName作为键(通过key返回的字串在当前文件相同)

// key_name type NSString
#define NDNSString(NSKeyName) \
_NDLOCAL_INNER_NS_STRING((NDString(__FILE__).getFileName(), NSKeyName)

// key_name type cString(null end)
#define NDCString(cStringKeyName) \
_NDLOCAL_INNER_CString_STRING(NDString(__FILE__).getFileName(), cStringKeyName)

#pragma mark 以"Common"+"_"+KeyName作为键(通过key返回的字串相同)

// key_name type NSString
#define NDCommonNSString(NSKeyName) \
_NDLOCAL_INNER_NS_STRING(@"Common", NSKeyName)

// key_name type cString(null end)
#define NDCommonCString(cStringKeyName) __NDLOCAL_INNER_C_STRING("Common", cStringKeyName)

////////////////////////////////////////////////////////////////////////////////
// 本地方接口(返回NSString),用法同上
// 1.NDNSString_RETNS
// 2.NDCString_RETNS
// 3.NDCommonNSString_RETNS
// 4.NDCommonCString_RETNS
// inline NSString* __NDLOCAL_INNER_STRING_RETNS(NSString* nsKeyName)
// {
// 	//return NSLocalizedStringWithDefaultValue(nsKeyName, @"lyol", [NSBundle mainBundle], nsKeyName, NULL);
// 	return NDLocalXmlString::GetSingleton().GetString(nsKeyName);
// }

#define _NDLOCAL_INNER_NS_STRING_RETNS( NSKeyFileName, NSKeyName) \
__NDLOCAL_INNER_STRING_RETNS("%s_%s", NSKeyFileName, NSKeyName)

#define _NDLOCAL_INNER_CString_STRING_RETNS( NSKeyFileName, cStringKeyName) \
__NDLOCAL_INNER_STRING_RETNS("%s_%s", NSKeyFileName, cStringKeyName])

#pragma mark 以文件名+"_"+KeyName作为键(通过key返回的字串在当前文件相同)-----返回NSString

// key_name type NSString
#define NDNSString_RETNS(NSKeyName) \
_NDLOCAL_INNER_NS_STRING_RETNS(NDString(__FILE__).getFileName(), NSKeyName)

// key_name type cString(null end)
#define NDCString_RETNS(cStringKeyName) \
_NDLOCAL_INNER_CString_STRING_RETNS(NSString(__FILE__).getFileName(), cStringKeyName)

#pragma mark 以"Common"+"_"+KeyName作为键(通过key返回的字串相同)-----返回NSString

// key_name type NSString
#define NDCommonNSString_RETNS(NSKeyName) \
_NDLOCAL_INNER_NS_STRING_RETNS(@"Common", NSKeyName)

// key_name type cString(null end)
#define NDCommonCString_RETNS(cStringKeyName) \
_NDLOCAL_INNER_CString_STRING_RETNS(@"Common", cStringKeyName)

#endif // _ND_LOCALIZATION_H_ZJH_