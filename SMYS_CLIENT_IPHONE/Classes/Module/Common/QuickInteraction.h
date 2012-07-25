/*
 *  QuickInteraction.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __QUICK_INTERACTION_H__
#define __QUICK_INTERACTION_H__

#include "define.h"
#include "NDUISpecialLayer.h"
#include "NDUIButton.h"
#include "NDBaseRole.h"
#include "NDUIDialog.h"

enum QUICK_INTERACTION {
	QI_BEGIN,
	QI_CLOSE_TEAM,		// 关闭加入
	QI_OPEN_TEAM,		// 开启加入
	QI_KICKOUT_TEAM,	// 踢出队伍
	QI_ASSIGN_TEAM_LEADER, // 提升队长
	QI_DISMISS_TEAM,	// 解散队伍
	QI_INVITE_TEAM,		// 邀请组队
	QI_JOIN_TEAM,		// 加入队伍
	QI_LEFT_TEAM,		// 离队
	QI_ADD_FRIEND,		// 加好友
	QI_REHERSE,			// 比武
	QI_WATCH_BATTLE,	// 观战
	QI_INVITE_SYNDICATE,// 军团邀请
	QI_BAI_SHI,			// 拜师
	QI_SHOU_TU,			// 收徒
	QI_SHOW_VENDOR,	// 查看摆摊
	QI_PK,				// PK
	QI_TRADE,			// 交易
	
	QI_SET,				// 设置
	QI_BACKTOMENU,		// 回主界面
	QI_RESET,			// 卡死复位
	QI_END,
};

typedef vector<QUICK_INTERACTION> VEC_QUICK_INTERACTION;

class QuickInteraction : 
public NDUIChildrenEventLayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(QuickInteraction)
	
	enum SHRINK_STATUS {
		SS_HIDE,
		SS_SHOW,
		SS_SHRINKING,
		SS_EXTENDING,
	};
	
public:
	static void RefreshOptions();
	QuickInteraction();
	~QuickInteraction();
	
	void Initialization(); override
	
	void OnBattleBegin(); override
	
	void draw();
	
	void OnButtonClick(NDUIButton* button);
	
	void SetShrink(bool bShrink);
	
	// 根据当前目标刷新快捷互动栏操作选项
	//void Refresh(NDBaseRole* target); ///< 临时性注释 郭浩
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void OnDialogClose(NDUIDialog* dialog); override
	
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	bool OnButtonDragOver(NDUIButton* overButton, bool inRange); override
	
	bool OnButtonLongClick(NDUIButton* button); override
	
	bool OnButtonLongTouch(NDUIButton* button); override
	
	void OnButtonDown(NDUIButton* button); override
	
	void OnButtonUp(NDUIButton* button); override
private:
	typedef vector<NDUIButton*> VEC_BTNS;
	
	SHRINK_STATUS m_status;
	
	NDUIButton* m_btnSwitch;
	
	NDUIButton* m_btnPlayerBag;
	
	NDUIButton* m_btnSystem;
	
	NDUIButton* m_btnMainUiBack;// 回主界面 //m_btnTrade; 
	
	NDUIButton* m_btnMail;
	
	NDUIButton* m_btnMainUiReset; //  卡死复位//m_btnPK;　　　
	
	NDUIButton* m_btnViewInfo;
	
	NDUIButton* m_btnPrivateTalk;
	
	NDUIChildrenEventLayer* m_secondBarLayer;
	
	NDUIDialog* m_dlgQueryVipShop, *m_dlgQueryTreasureHunt;
	
	VEC_BTNS m_vSecondBarBtns;
	
	NDPicture* m_picEmptyBtn;
	NDPicture* m_picInviteTeam, *m_picJoinTeam, *m_picLeftTeam;
	NDPicture* m_picCloseTeam, *m_picOpenTeam, *m_picKickOutTeam;
	NDPicture* m_picDismissTeam, *m_picAssignTeamLeader;
	NDPicture* m_picAddFriend, *m_picReherse, *m_picWatchBattle;
	NDPicture* m_picInviteSyn, *m_picBaiShi, *m_picShouTu;
	NDPicture* m_picShowVendor;
	NDPicture* m_picTrade, *m_picPk;
	
	NDPicture* m_picSysSet, *m_picSysBackToMenu, *m_picSysReset;
	
	VEC_QUICK_INTERACTION m_vOpts;
	
	size_t m_secondBarShowIndex;
	
	static QuickInteraction* s_instance;
	
	CAutoLink<NDUIMaskLayer> m_layerMask;
	
	NDUIChildrenEventLayer* m_firstLayer;
private:
	void SetBtnImgByOpt(NDUIButton* btn, QUICK_INTERACTION qi);
	void DealTreasureHunt();
	void ShowMask(bool show, NDPicture* pic=NULL);
	void RefreshSystem();
	void ResetSecondBar();
};

#endif