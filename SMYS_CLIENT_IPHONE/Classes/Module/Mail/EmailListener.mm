/*
 *  EmailListener.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "EmailListener.h"
#include "EmailRecvScene.h"
#include "NDUISynLayer.h"
#include "EmailData.h"
#include "NDMapMgr.h"
#include "define.h"
#include "Chat.h"
#include "GameScene.h"
#include <string>
#include "NDDataPersist.h"
#include "NDPlayer.h"
#include "NewMail.h"
#include <sstream>

void EmailListener::processMsg(int serviceCode, NDTransData& data)
{
	switch (serviceCode) {
		case _MSG_LETTER:// 1
			dealBackData_MSG_RECEIED_LETTER(data);
			break;
		case _MSG_LETTER_INFO:// 1
			dealBackData_MSG_LETTER_INFO(data);
			break;
		case _MSG_LETTER_REQUEST:// 1
			dealBackData_MSG_LETTER_REQUEST(data);
			break;
	}
}

void EmailListener::dealBackData_MSG_RECEIED_LETTER(NDTransData& data) {
	int m = data.ReadByte(); // 低两位是表action高六位表邮件个数
	int btAction = (m & 3); // 邮件的action
	int count = m >> 2; // 邮件的个数
	
	for (int i = 0; i < count; i++) {
		int emailId = data.ReadInt();
		long uSendTime = data.ReadInt();
		short btAttachState = (short) data.ReadByte();
		std::string name = data.ReadUnicodeString();
		
		EmailData *email = new EmailData(emailId, uSendTime, name);
		email->setMAttachState(btAttachState);
		email->setReadState(EmailData::STATE_NOT_READ);
		
		vec_email& mails = NDMapMgrObj.m_vEmail;
		mails.push_back(email);
		
		//检查、保存到rms
		//byte[] emailStatebys = T.getRmsValue(EmailData::MARK+emailId); 
//			if (null == emailStatebys) {
//				T.saveRmsValue(EmailData.MARK+emailId, new byte[] {EmailData.STATE_NOT_READ});
//				UIRootViewController.getInstance().flashMail(true);
//			}else {
//				if (EmailData.STATE_HAS_READ == emailStatebys[0]) {
//					email.setReadState(EmailData.STATE_HAS_READ);
//				}
//			}
		NDPlayer& player = NDPlayer::defaultHero();
		NDEmailDataPersist& datapersist = NDEmailDataPersist::DefaultInstance();
		std::stringstream ssmail; ssmail << EmailData::MARK << emailId;
		std::string mail = datapersist.GetEmailState(player.m_id, ssmail.str());
		if (mail.empty()) 
		{
			std::stringstream mailstate; mailstate << EmailData::STATE_NOT_READ;
			datapersist.AddEmail(player.m_id, ssmail.str(), mailstate.str());
			//UIRootViewController.getInstance().flashMail(true);
		}
		else 
		{
			int  iState = atoi(mail.c_str());
			if (EmailData::STATE_HAS_READ == iState) {
					email->setReadState(EmailData::STATE_HAS_READ);
			}
		}

		GameMailsScene::UpdateMail();
		NewMailUILayer::refresh();
		
		// 新聊天信息到,屏幕下方显示
		if (btAction == LETTER_NEW)
		{	
			std::stringstream ss;
			if (NDMapMgrObj.isFriendAdded(name)) {
				 ss << NDCommonCString("YourFriend") << " " << name << " " << NDCString("SendMailToYou");
				Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
				//GameScreen.getInstance().initNewChat(new ChatRecord(5, "系统", "您的好友 " + name + " 给您发了一封邮件,请查收."), true);
			} else if (name == NDCommonCString("system") ){
				ss << NDCommonCString("system") << NDCString("SendMailToYou");
				Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
				//GameScreen.getInstance().initNewChat(new ChatRecord(5, NDCommonCString("system"), "系统给您发了一封邮件,请查收."), true);
			} else {	
				std::stringstream ss; ss << NDCommonCString("player") << " " << name << " " << NDCString("SendMailToYou");
				Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
				//GameScreen.getInstance().initNewChat(new ChatRecord(5, NDCommonCString("system"), "玩家 " + name + " 给您发了一封邮件,请查收."), true);
			}
			
			NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
			if (scene) 
			{
				GameScene* gamescene = (GameScene*)scene;
				gamescene->flashAniLayer(1, true);
			}
			
		
			RequsetInfo info;
			info.set(0, ss.str(), RequsetInfo::ACTION_NEWMAIL);
			NDMapMgrObj.addRequst(info);
		}
	}
}

void EmailListener::dealBackData_MSG_LETTER_INFO(NDTransData& data) {
	int emailId = data.ReadInt();
	long uFailTime = data.ReadInt();
	int btLetterInfo = data.ReadByte();
	
	vec_email& mails = NDMapMgrObj.m_vEmail;
	for_vec(mails, vec_email_it)
	{
		EmailData& email = *(*it);
		if (email.getId() == emailId) {
			email.setBtLetterInfo(btLetterInfo);
			if (email.isHaveItem()) { // 附件
				int itemID = data.ReadInt();
				int itemType = data.ReadInt();
				int dwAmount = data.ReadShort();
				
				Item *item = new Item();
				item->iID = itemID;
				item->iItemType = itemType;
				item->iAmount = dwAmount;
				email.setMIncludeItem(item);
				
			}
			if (email.isHaveMoney()) { // money
				int money = data.ReadInt();
				email.setMGetMoney(money);
				
			}
			if (email.isHaveEMoney()) { // emoney
				int emoney = data.ReadInt();
				email.setMGetEMoney(emoney);
			}
			if (email.isHavePayMoney()) { // pay_money
				int pay_money = data.ReadInt();
				email.setMPayMoney(pay_money);
			}
			if (email.isHavePayEMoney()) { // pay_emoney
				int pay_emoney = data.ReadInt();
				email.setMPayEMoney(pay_emoney);
			}
			
			std::string content = data.ReadUnicodeString();
			email.setMContent(content);
			email.setMTimeLimit(uFailTime);
			if (email.getMState() != EmailData::STATE_HAS_READ) {
				email.setReadState(EmailData::STATE_HAS_READ);
				//T.saveRmsValue(EmailData.MARK+email.getId(), new byte[]{EmailData.STATE_HAS_READ}); 
				NDPlayer& player = NDPlayer::defaultHero();
				NDEmailDataPersist& datapersist = NDEmailDataPersist::DefaultInstance();
				std::stringstream ssmail; ssmail << EmailData::MARK << email.getId();
				std::stringstream mailstate; mailstate << EmailData::STATE_HAS_READ;
				datapersist.AddEmail(player.m_id, ssmail.str(), mailstate.str());
			}
			
			CloseProgressBar;
			
			GameMailsScene::UpddateMailInfo();
			GameMailsScene::UpdateMail();
			NewMailUILayer::refresh();
			break;
		}
	}
}

void EmailListener::dealBackData_MSG_LETTER_REQUEST(NDTransData& data) {
	int emailId = data.ReadInt();
	int action = data.ReadByte();
	
	vec_email& mails = NDMapMgrObj.m_vEmail;
	
	switch (action) {
		case ATTACH_ACCEPT_SUCCESS: { // 接收附件成功
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("AcceptAttachSucess"));
			
			//dialog = new Dialog(NDCommonCString("SystemInfo"), "接收附件成功", Dialog.PRIV_HIGH);
			for (int i = 0; i < int(mails.size()); i++) {
				EmailData& email = *(mails[i]);
				if (email.getId() == emailId) {
					email.setMAttachState(EmailData::ATTACH_ACCEPTION);
					GameMailsScene::UpddateMailInfo();
					NewMailUILayer::refresh();
					break;
				}
			}
			break;
		}
		case ATTACH_ACCEPT_NOT_ENOUGH_MONEY: { // 银两不足
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("AcceptAttachFailMoney"));
			break;
		}
		case ATTACH_ACCEPT_NOT_ENOUGH_EMONEY: { // 元宝不足
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("AcceptAttachFailEMoney"));
			break;
		}
		case ATTACH_ACCEPT_BAG_FULL: { // 背包已满
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("AcceptAttachFailBag"));
			break;
		}
		case ATTACH_ACCEPT_FAIL: { // 其它异常引起的失败
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("AcceptAttachFail"));
			break;
		}
		case ATTACH_REJECT_SUCCESS: {// 拒收成功
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("RejectSucess"));
			for (int i = 0; i < int(mails.size()); i++) {
				EmailData& email = *(mails[i]);
				if (email.getId() == emailId) {
					email.setMAttachState(EmailData::ATTACH_REJECTION);
					GameMailsScene::UpddateMailInfo();
					NewMailUILayer::refresh();
					break;
				}
			}
			
			break;
		}
		case ATTACH_REJECT_FAIL: { // 其它异常引起的失败
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("RejectFail"));
			break;
		}
		case LETTER_DEL_SUCCESS: { // 删除邮件成功
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("DelMailSucess"));
			for (int i = 0; i < int(mails.size()); i++) {
				EmailData& email = *(mails[i]);
				if (email.getId() == emailId) {
					//T.deleteRMS(EmailData.MARK + emailId); 
					NDPlayer& player = NDPlayer::defaultHero();
					NDEmailDataPersist& datapersist = NDEmailDataPersist::DefaultInstance();
					std::stringstream ssmail; ssmail << EmailData::MARK << email.getId();
					datapersist.DelEmail(player.m_id, ssmail.str());
					mails.erase(mails.begin()+i);
					break;
				}
			}
			GameMailsScene::UpdateMail();
			NewMailUILayer::refresh();
			break;
		}
		case LETTER_DEL_ATTACH_NOT_ALLOW: {// 有附件禁止删除
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("DelMailFailAttach"));
			break;
		}
		case ATTACH_REJECT_SYSTEM_NOT_ALLOWED: {
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("SysMailErr"));
			break;
		}
		case LETTER_DEL_FAIL: {// 其它异常引起的失败
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCString("DelMailFail"));
			break;
		}
		default: {
			GlobalShowDlg(NDCommonCString("SystemInfo"), NDCommonCString("OperateExcept"));
			break;
		}
	}
	
}