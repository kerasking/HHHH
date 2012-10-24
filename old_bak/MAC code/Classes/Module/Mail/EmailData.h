/*
 *  EmailData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _EMAIL_DATA_H_
#define _EMAIL_DATA_H_

#include "Item.h"
#include <string>

class EmailData 
{
public:
	enum
	{
		STATE_NOT_READ = 0, // 未读或无附件
		STATE_HAS_READ = 5, // 未读或无附件
		
		STATE_HAVE_ITEM = 1, // 有附件未接收
		
		STATE_ACCEPT = 2 , // 已接收
		
		STATE_REJECT =  3, // 已拒收
		
		STATE_WITHDRAWAL = 4, // 已退回
	};
public:
	 EmailData();
	
	 EmailData(int iid, long time, std::string nameStr);
	
	 EmailData(int iid, long time, std::string nameStr, int attachState);
	 
	 ~EmailData();
	 
	 void Init();
	
	 std::string getMFailTimeStr(long time);// 失效时间
	
	 void setMTimeLimit(long failTime);
	 int getId();
	
	 void setId(int id);
	
	//	 int getState() {
	//		return mState;
	//	}
	//
	//	 void setState(int state) {
	//		mState = state;
	//	}
	
	 int getMItemtype();
	
	 void setMItemtype(int itemtype);
	
	 int getMItemCount();
	
	 void setMItemCount(int itemCount);
	
	 std::string getMTimeLimit();
	 int getMGetMoney();
	 void setMGetMoney(int getMoney);
	
	 int getMGetEMoney();
	
	 void setMGetEMoney(int getEMoney);
	
	 int getMPayMoney();
	
	 void setMPayMoney(int payMoney);
	
	 int getMPayEMoney();
	
	 void setMPayEMoney(int payEMoney);
	
	 std::string getMContent();
	
	 void setMContent(std::string content);
	
	 std::string getMTimeStr();
	
	 std::string getMNameStr();
	
	 void setMNameStr(std::string nameStr);
	
	 Item* getMIncludeItem();
	
	 void setMIncludeItem(Item* includeItem);
	
	 std::string getMItemStr();
	
	 void setMItemStr(std::string itemStr);
	
	 int getSumCache();
	
	 std::string getMStateStr();
	
	 int getMAttachState();
	
	 void setMAttachState(int attachState);
	
	/*
	 * 这里控制邮件列表中的显示情况
	 */
	private:
		void setMStateStr();
	
	public:
	 int getMState();
	
	 void setMState(int state);
	
	 int getReadState();
	 void setReadState(int state);
	
	 bool isHaveItem();
	
	 bool isHaveMoney();
	
	 bool isHaveEMoney();
	
	 bool isHavePayMoney();
	
	 bool isHavePayEMoney();
	
	 int getBtLetterInfo();
	
	 void setBtLetterInfo(int iLetterInfo);
protected:
	std::string GetDateBySecond(long nSecond);
public:
	static std::string MARK;
private:
	int mId; // 邮件id
	
	std::string  mTimeStr; // 邮件时间
	
	std::string  mNameStr; // 邮件姓名
	
	std::string  mContent; // 邮std::string 件正文
	
	std::string mStateStr;
	
private:
	int  mState; // 主要控制附件状态
	
	int  mReadState; //控制是否读过
	
	int  mItemtype; // -1表无物品,其他时候为itemType
	
	int  mItemCount; // 物品个数
	
	std::string mTimeLimit; // 限定时间
	
	int  mGetMoney, mGetEMoney; // 邮件得到银币跟金币
	
	int  mPayMoney, mPayEMoney; // 收邮件附件所要支付的银币跟金币
	
	int  sumCache;
	
	Item *mIncludeItem;
	
	std::string mItemStr;
	
	int mAttachState;
	
	int  btLetterInfo;
public:	
	enum
	{
		ATTACH_NO = 0x00, // 没有附件
		ATTACH_ITEM_ID = 0x01, // 附件含 item
		ATTACH_ITEM_TYPE = 0x02, // 附件为 itemtype
		// (客户端并不发这个值,由服务端判断item_id字段是否改成type)
		ATTACH_MONEY = 0x04, // 附件含 attach_money
		ATTACH_EMONEY = 0x08, // 附件含 attach_emoney
		ATTACH_REQUIRE_MONEY = 0x10, // 附件含 require_money
		ATTACH_REQUIRE_EMONEY = 0x20, // 附件含 require_emoney
		ATTACH_ACCEPTION = 0x40, // 附件已接收
		ATTACH_REJECTION = 0x80, // 附件已拒收
		ATTACH_WITHDRAWAL = 0xC0, // 附件已退回
	};
	
	enum{ INFO_ATTACH_ITEM_ID = 0x01, INFO_TTACH_MONEY = 0x02, INFO_ATTACH_EMONEY = 0x04, INFO_ATTACH_REQUIRE_MONEY = 0x08, INFO_ATTACH_REQUIRE_EMONEY = 0x10, };
	
};

#endif //_EMAIL_DATA_H_