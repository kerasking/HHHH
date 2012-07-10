/*
 *  EmailData.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "EmailData.h"
#include "NDUtility.h"
#include <sstream>
#include "NDString.h"

std::string EmailData::MARK = "emailId_";
	
EmailData::EmailData() 
{
	 Init();
}

EmailData::EmailData(int iid, long time, std::string nameStr) {
	Init();
	mId = iid;
	mNameStr = nameStr;
	mTimeStr = getStringTime(time);
}

EmailData::EmailData(int iid, long time, std::string nameStr, int attachState) 
{
	Init();
	
	mId = iid;
	mNameStr = nameStr;
	mTimeStr = getStringTime(time);
	
	setMAttachState(attachState);
}

EmailData::~EmailData()
{
	if (mIncludeItem) 
	{
		delete mIncludeItem;
	}
}

void EmailData::Init()
{
	mState = STATE_NOT_READ; // 主要控制附件状态
	
	mReadState = STATE_NOT_READ; //控制是否读过
	
	mItemtype = -1; // -1表无物品,其他时候为itemType
	
	mItemCount = 0; // 物品个数
	
	mTimeLimit = ""; // 限定时间
	
	mGetMoney = 0; mGetEMoney = 0; // 邮件得到银两跟元宝
	
	mPayMoney = 0; mPayEMoney = 0; // 收邮件附件所要支付的银两跟元宝
	
	mIncludeItem = NULL;
}

std::string EmailData::GetDateBySecond(long nSecond)
{
	uint nDay = TimeConvert(TIME_DAY, nSecond);
	NDString strDate;
	strDate.Format("%d%s%d%s", nDay%10000/100, NDCommonCString("month"), 
				   nDay%100, NDCommonCString("day"));
	
	return strDate;
}

std::string EmailData::getMFailTimeStr(long time) { // 失效时间
	if (time != 0) {
		return this->GetDateBySecond(time);
	} else {
		return NDCommonCString("yongjiu");
	}
}

void EmailData::setMTimeLimit(long failTime) {
	mTimeLimit = getMFailTimeStr(failTime); // 服务器发的是秒
}

int EmailData::getId() {
	return mId;
}

void EmailData::setId(int id) {
	mId = id;
}

//	int getState() {
//		return mState;
//	}
//
//	void setState(int state) {
//		mState = state;
//	}

int EmailData::getMItemtype() {
	return mItemtype;
}

void EmailData::setMItemtype(int itemtype) {
	mItemtype = itemtype;
}

int EmailData::getMItemCount() {
	return mItemCount;
}

void EmailData::setMItemCount(int itemCount) {
	mItemCount = itemCount;
}

std::string EmailData::getMTimeLimit() {
	return mTimeLimit;
}

int EmailData::getMGetMoney() {
	return mGetMoney;
}

void EmailData::setMGetMoney(int getMoney) {
	mGetMoney = getMoney;
}

int EmailData::getMGetEMoney() {
	return mGetEMoney;
}

void EmailData::setMGetEMoney(int getEMoney) {
	mGetEMoney = getEMoney;
}

int EmailData::getMPayMoney() {
	return mPayMoney;
}

void EmailData::setMPayMoney(int payMoney) {
	mPayMoney = payMoney;
}

int EmailData::getMPayEMoney() {
	return mPayEMoney;
}

void EmailData::setMPayEMoney(int payEMoney) {
	mPayEMoney = payEMoney;
}

std::string EmailData::getMContent() {
	return mContent;
}

void EmailData::setMContent(std::string content) {
	mContent = content;
}

std::string EmailData::getMTimeStr() {
	return mTimeStr;
}

std::string EmailData::getMNameStr() {
	return mNameStr;
}

void EmailData::setMNameStr(std::string nameStr) {
	mNameStr = nameStr;
}

Item* EmailData::getMIncludeItem() {
	return mIncludeItem;
}

void EmailData::setMIncludeItem(Item *includeItem) {
	if (!includeItem) 
	{
		mIncludeItem = NULL;
		return;
	}
	mIncludeItem = includeItem;
	//mIncludeItem->getItemTypes();
	
	std::string name = mIncludeItem->getItemName();
	
	int count = mIncludeItem->iAmount;
	if (includeItem->isEquip()) {// type 0表示装备
		setMItemStr(name);
	} else {
		std::stringstream ss; ss << name << " x " << count;
		setMItemStr(ss.str());
	}
}

std::string EmailData::getMItemStr() {
	return mItemStr;
}

void EmailData::setMItemStr(std::string itemStr) {
	mItemStr = itemStr;
}

int EmailData::getSumCache() {
	return sumCache;
}

std::string EmailData::getMStateStr() {
	return mStateStr;
}

int EmailData::getMAttachState() {
	return mAttachState;
}

void EmailData::setMAttachState(int attachState) {
	mAttachState = attachState;
	setMStateStr();
}

/*
 * 这里控制邮件列表中的显示情况
 */
 void EmailData::setMStateStr() {
	std::stringstream ss;
	
	if (((mAttachState & ATTACH_ITEM_ID) == ATTACH_ITEM_ID) //附件
		|| (mAttachState & ATTACH_MONEY) == ATTACH_MONEY  //银两
		|| (mAttachState & ATTACH_EMONEY) == ATTACH_EMONEY) { //元宝
		ss << (NDCommonCString("AttachGuo"));
		mState = STATE_HAVE_ITEM;
	}
	
	if (mAttachState == ATTACH_ACCEPTION) { // 附件已接收
		ss << "[" << NDCommonCString("yi") << NDCommonCString("accept") << "]";
		mState = STATE_ACCEPT;
	} else if (mAttachState == ATTACH_REJECTION) { // 附件已拒收
		ss << "[" << NDCommonCString("yi") << NDCommonCString("JuShou") << "]";
		mState = STATE_REJECT;
	} else if (mAttachState == ATTACH_WITHDRAWAL) { // 附件已退回
		ss << "[" << NDCommonCString("yi") << NDCommonCString("tuihui") << "]";
		mState = STATE_WITHDRAWAL;
	} else if (STATE_NOT_READ == mReadState) {
		ss << "[" << NDCommonCString("noread") << "]";
	} else if (STATE_HAS_READ == mReadState) {
		ss << "[" << NDCommonCString("hadread") << "]";
	}
	//sumCache = T.stringWidth(mNameStr + mStateStr.toString());
	
	mStateStr = ss.str();
}

int EmailData::getMState() {
	return mState;
}

void EmailData::setMState(int state) {
	mState = state;
	setMStateStr();
}

int EmailData::getReadState() {
	return mReadState;
}
void EmailData::setReadState(int state) {
	mReadState = state;
	setMStateStr();
}

bool EmailData::isHaveItem() {
	if ((btLetterInfo & INFO_ATTACH_ITEM_ID) == INFO_ATTACH_ITEM_ID) {
		return true;
	}
	return false;
}

bool EmailData::isHaveMoney() {
	if ((btLetterInfo & INFO_TTACH_MONEY) == INFO_TTACH_MONEY) {
		return true;
	}
	return false;
}

bool EmailData::isHaveEMoney() {
	if ((btLetterInfo & INFO_ATTACH_EMONEY) == INFO_ATTACH_EMONEY) {
		return true;
	}
	return false;
}

bool EmailData::isHavePayMoney() {
	if ((btLetterInfo & INFO_ATTACH_REQUIRE_MONEY) == INFO_ATTACH_REQUIRE_MONEY) {
		return true;
	}
	return false;
}

bool EmailData::isHavePayEMoney() {
	if ((btLetterInfo & INFO_ATTACH_REQUIRE_EMONEY) == INFO_ATTACH_REQUIRE_EMONEY) {
		return true;
	}
	return false;
}

int EmailData::getBtLetterInfo() {
	return btLetterInfo;
}

void EmailData::setBtLetterInfo(int iLetterInfo) {
	btLetterInfo = iLetterInfo;
}