/*
 *  EmailListener.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _EMAIL_LISTENER_H_
#define _EMAIL_LISTENER_H_

#include "NDTransData.h"

using namespace NDEngine;

class EmailListener
{
	enum
	{
		LETTER_EXIST = 0,

		LETTER_NEW = 1,

		ATTACH_ACCEPT_SUCCESS = 0, // 接收附件成功
	};
	
	enum
	{
		ATTACH_ACCEPT_NOT_ENOUGH_MONEY = 1, // 银两不足
		ATTACH_ACCEPT_NOT_ENOUGH_EMONEY = 2, // 元宝不足
		ATTACH_ACCEPT_BAG_FULL = 3, // 背包已满
		ATTACH_ACCEPT_FAIL = 4, // 其它异常引起的失败
		
		ATTACH_REJECT_SUCCESS = 5, // 拒收成功
		ATTACH_REJECT_SYSTEM_NOT_ALLOWED = 6, // 系统附件不允许拒收
		ATTACH_REJECT_FAIL = 7, // 其它异常引起的失败
		
		LETTER_DEL_SUCCESS = 8, // 删除邮件成功
		LETTER_DEL_ATTACH_NOT_ALLOW = 9, // 有附件禁止删除
		LETTER_DEL_FAIL = 10, // 其它异常引起的失败
	};
public:
	static void processMsg(int serviceCode, NDTransData& data);	
private:
	static void dealBackData_MSG_RECEIED_LETTER(NDTransData& data);	
	static void dealBackData_MSG_LETTER_INFO(NDTransData& data);	
	static void dealBackData_MSG_LETTER_REQUEST(NDTransData& data);	
};

#endif // _EMAIL_LISTENER_H_