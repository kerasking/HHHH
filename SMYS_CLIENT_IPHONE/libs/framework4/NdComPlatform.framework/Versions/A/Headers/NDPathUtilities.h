//
//  NDPathUtilities.h
//  Untitled
//
//  Created by xujianye on 11-2-15.
//  Copyright 2011 NetDragon WebSoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSPathUtilities.h>

/**
 @brief 判断当前设备是否已经越狱，YES表示已经越狱
 @n<b>函数名称</b>		:NDIsJailBreak:
 @note 支持iphone, ipad, ipod
 */
BOOL NDIsJailBreak();

/**
 @brief 封装NSSearchPathForDirectoriesInDomains函数，对越狱的设备进行特殊处理。
 @n<b>函数名称</b>		:NDSearchPathForDirectoriesInDomains:
 @note 针对NSDocumentDirectory中NSUserDomainMask的情况：
		如果是越狱的设备，在当前app目录下创建Documents目录（如果不存在的情况），并返回该目录。不支持expandTilde = NO的情况。
		目前仅支持doc目录，其他情况都默认返回NSSearchPathForDirectoriesInDomains系统结果。
 */
NSArray *NDSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

