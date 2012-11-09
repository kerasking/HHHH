/*
 *  Battle.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_H__
#define __BATTLE_H__

#include "define.h"
#include "EnumDef.h"
#include "NDUILayer.h"
#include <vector>
#include "NDUIButton.h"
#include "NDTimer.h"
#include "NDUIImage.h"
//#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include <map>
#include "Fighter.h"
#include "BattleSkill.h"
#include "BattleUtil.h"
#include "NDSprite.h"
//#include "PlayerHead.h"
#include "NDEraseInOutEffect.h"
#include "StatusDialog.h"
#include "NDUtility.h"
//#include "NDUIFighterSpeedBar.h"
//#include "GameUIItemConfig.h"
#include "NDMapLayer.h"
#include "SMBattleScene.h"
#include "BattleMgr.h"
#include "..\..\TempClass\NDBaseBattle.h"

#define BTN_ATTATCK 1
#define BTN_ITEM 2
#define BTN_SKILL 3
#define BTN_DEFENCE 4
#define BTN_AUTO 5
#define BTN_FLEE 6
#define BTN_CATCH 7

#define CELL_TAG_CATCH 1
#define CELL_TAG_FLEE 2
#define CELL_TAG_DEF 3
#define CELL_TAG_ATK 4
#define CELL_TAG_VIEWSTATUS 5

#define BTN_CANCLE_AUTO 8

enum
{
	BTN_EUD_ATK = 30,
	BTN_EUD_ITEM,
	BTN_EUD_SKILL,
	BTN_EUD_DEF,
	BTN_EUD_FLEE,
};

#define BTN_TALK 50

#define TAG_LINGPAI 100
#define TAG_NAME 101
#define TAG_WAITING 102
#define TAG_TIMER 103
#define TAG_AUTO_LABEL 104
#define TAG_AUTO_NUM_IMG 105
#define TAG_VIEW_FIGHTER_STATUS 106

#define TAG_SKILL_NAME 1000
#define TAG_SKILL_MEMO 1001
#define TAG_HOVER_MSG 1002
#define TAG_FIGHTER_NAME 1003

using namespace std;
using namespace NDEngine;

enum BATTLE_COMPLETE
{
	BATTLE_COMPLETE_LOSE = 0,
	BATTLE_COMPLETE_WIN = 1,
	BATTLE_COMPLETE_NO = 2,
	BATTLE_COMPLETE_END = 3,
};

class HighlightTipStatusBar: public NDUINode
{
	DECLARE_CLASS (HighlightTipStatusBar)
public:
	HighlightTipStatusBar()
	{
		m_nNum = 0;
		m_nNumMax = 0;
		m_color = 0;
	}

	HighlightTipStatusBar(int nColor)
	{
		m_nNum = 0;
		m_nNumMax = 0;
		m_color = nColor;
	}
	~HighlightTipStatusBar()
	{

	}
	void draw()
	{
		CGRect rect = this->GetFrameRect();
		drawRectBar2(rect.origin.x, rect.origin.y, m_color, m_nNum, m_nNumMax,
				rect.size.width);
	}
	void SetNum(int nNum, int nNumMax)
	{
		m_nNum = nNum;
		m_nNumMax = nNumMax;
	}

private:
	int m_nNum;
	int m_nNumMax;
	int m_color;
};

class HighlightTip: public NDUILayer
{
	DECLARE_CLASS (HighlightTip)
public:
	HighlightTip();
	~HighlightTip();

	void Initialization();
	void SetFighter(Fighter* pkFighter);

private:
	NDPicture* m_pkPicBubble;

	HighlightTipStatusBar* m_hpBar;
	HighlightTipStatusBar* m_mpBar;

	ImageNumber* m_imgNumHp;
	ImageNumber* m_imgNumMp;
};

class NDAnimationGroup;
class BattleAction
{
public:
	BattleAction(BATTLE_ACTION action)
	{
		btAction = Byte(action);
	}

	Byte btAction;
	vector<int> vData;
};

enum TEAM_STATUS
{
	TEAM_NONE = ID_NONE,
	TEAM_WAIT,
	TEAM_FIGHT,
	TEAM_OVER,
};

struct Command
{
	Command()
	{
		memset(this, 0L, sizeof(Command));
	}

	~Command()
	{

	}

	int btEffectType;
	int idActor;
	int idTarget;
	int nHpLost;
	int nMpLost;

	/**
	 * 该命令所使用的技能,由服务端下发,含技能id,名字,atkType(id亿位解析出来)
	 */
	BattleSkill* skill;
	FighterStatus* status;
	Command* cmdNext; //command连锁
	bool complete;
};

typedef vector<Command *> VEC_COMMAND;
typedef VEC_COMMAND::iterator VEC_COMMAND_IT;

class ImageNumber;

typedef vector<NDSubAniGroup> VEC_SUB_ANI_GROUP;
typedef VEC_SUB_ANI_GROUP::iterator VEC_SUB_ANI_GROUP_IT;

class IsSubAniGroupComplete
{
public:
	bool operator()(NDSubAniGroup& sag)
	{
		return sag.bComplete;
	}
};

typedef int CoolDownID;
typedef int CoolDownData;
typedef std::map<CoolDownID, CoolDownData> CoolDownRecord;
typedef CoolDownRecord::iterator CoolDownRecord_IT;
typedef std::pair<CoolDownID, CoolDownData> CoolDownRecord_Pair;

class Battle:
	public NDUILayer,
	public NDBaseBattle,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
		public NDUIDialogDelegate,
//public NDUISpeedBarDelegate,
		public NDUIButtonDelegate
//public GameUIItemConfigDelegate
{
	DECLARE_CLASS (Battle)
public:
	enum BATTLE_STATUS
	{
		BS_BATTLE_WAIT,
//		BS_USER_MENU,
//		BS_EUDEMON_MENU,
//		BS_USE_ITEM_MENU,
//		BS_EUDEMON_USE_ITEM_MENU,
//		BS_USER_SKILL_MENU,
//		BS_EUDEMON_SKILL_MENU,
//		BS_CHOOSE_VIEW_FIGHTER_STATUS,
//		BS_CHOOSE_VIEW_FIGHTER_STATUS_PET,
//		BS_CHOOSE_ENEMY_PHY_ATK,	// 普通攻击，选择敌人
//		BS_CHOOSE_ENEMY_MAG_ATK,	// 技能攻击，选择敌人
//		BS_CHOOSE_OUR_SIDE_MAG_ATK,
//		BS_CHOOSE_SELF_MAG_ATK,
//		BS_CHOOSE_SELF_MAG_ATK_EUDEMON,
//		BS_CHOOSE_ENEMY_CATCH,
//		BS_CHOOSE_OUR_SIDE_USE_ITEM_USER,
//		BS_CHOOSE_OUR_SIDE_USE_ITEM_EUDEMON,
//		BS_CHOOSE_ENEMY_PHY_ATK_EUDEMON,
//		BS_CHOOSE_ENEMY_MAG_ATK_EUDEMON,
//		BS_CHOOSE_OUR_SIDE_MAG_ATK_EUDEMON,

		BS_SET_FIGHTER,				// 设置攻击动作
		BS_SHOW_FIGHT,				// 表现攻击动作
		BS_FIGHTER_SHOW_PAS,
		BS_BATTLE_COMPLETE,
		BS_WAITING_SERVER_MESSAGE,	// 等待服务端消息
	};

	Battle();
	Battle(Byte btType);
	~Battle();

	static void ResetLastTurnBattleAction();

	void InitSpeedBar();
	void InitEudemonOpt();
	void Initialization(int action);
	virtual bool TouchEnd(NDTouch* touch);override
	void draw();override
	void drawSubAniGroup();
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
			unsigned int cellIndex, NDSection* section);

	void AddFighter(Fighter* f);

	void SetFighterOnline(int idFighter, bool bOnline);

	Fighter* GetMainUser();
	Fighter* getMainEudemon();

	bool IsPracticeBattle()
	{
		return m_battleType == BATTLE_TYPE_PRACTICE;
	}

	int GetBattleType()
	{
		return m_battleType;
	}

	void SetTurn(int turn);

	void StartFight();

	void RestartFight();

	void dealWithCommand();

	void AddCommand(Command* cmd);

	void AddActionCommand(FightAction* action);

	virtual void OnTimer(OBJID tag);

//	virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
//	
//	virtual void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);

	virtual void OnDialogClose(NDUIDialog* dialog);

	virtual void OnButtonClick(NDUIButton* button);

	void processBattleSkillList(NDTransData& data, int len);

	void setBattleMap(int mapId, int posX, int posY);
	void setSceneCetner(int center_x, int center_y)
	{
		this->sceneCenterX = center_x;
		this->sceneCenterY = center_y;
	}
	NDPicture* GetBaoJiPic()
	{
		return m_picBaoJi;
	}
//	
//	NDPicture* GetBojiPic() {
//		return m_picBoji;
//	}

	int getServerBattleResult()
	{
		return serverBattleResult;
	}

	void setServerBattleResult(int result)
	{
		serverBattleResult = result;
	}

	void setBattleStatus(BATTLE_STATUS status);

	NDPicture* getActionWord(ACTION_WORD index);

	void setRewardContent(const char* pszContent)
	{
		this->m_rewardContent = pszContent;
	}

	void addSubAniGroup(NDSprite* role, NDAnimationGroup* group, Fighter* f);

	VEC_SUB_ANI_GROUP& getSubAniGroups()
	{
		return this->m_vSubAniGroup;
	}

	bool IsWatch()
	{
		return this->m_bWatch;
	}

	void sortFighterList();

	int getTurn()
	{
		return m_turn;
	}

	void setTeamAmout(int teamAmout)
	{
		this->m_teamAmout = teamAmout;
	}

	bool OnRoleDisapper(int iRoleID);

	bool CanPetFreeUseSkill();
	void FinishBattle();
private:
	Battle(const Battle& rhs)
	{
	}
	Battle& operator =(const Battle& rhs)
	{
		return *this;
	}

	static bool ms_bAuto;
	static BattleAction ms_kLastTurnActionUser;
	static BattleAction ms_kLastTurnActionEudemon;

	bool m_bTurnStart;
	bool m_bTurnStartPet;
	BATTLE_ACTION m_defaultActionUser;
	Fighter* m_pkDefaultTargetUser;
	int m_nDefaultSkillID;
	BATTLE_ACTION m_defaultActionEudemon;
	Fighter* m_defaultTargetEudemon;
	int m_defaultSkillIDEudemon;
	int m_nLastSkillPageUser;
	int m_nLastSkillPageEudemon;
	NDAnimationGroup* dieAniGroup;
	typedef vector<Command*> VEC_COMMAND;
	typedef VEC_COMMAND::iterator VEC_COMMAND_IT;

	typedef pair<int/*idItem*/, int/*num*/> PAIR_ID_NUM;
	typedef map<OBJID/*idItemType*/, PAIR_ID_NUM> MAP_USEITEM;
	typedef MAP_USEITEM::iterator MAP_USEITEM_IT;

	MAP_USEITEM m_mapUseItem;

	VEC_FIGHTER m_vAttaker;	// 进攻方
	VEC_FIGHTER m_vDefencer;	// 防御方

	Fighter* m_mainFighter; // 玩家自己
	Fighter* m_mainEudemon; // 玩家的宠物

	Fighter* theActor;
	Fighter* theTarget;
	int currentShowFighter;

//	NDPicture *m_picTalk; NDUIButton *m_btnTalk;
//	NDPicture *m_picQuickTalk; NDUIButton *m_btnQuickTalk;NDUILayer *m_layerBtnQuitTalk;
//	NDPicture *m_picLeave; NDUIButton* m_btnLeave;
//	NDPicture *m_picAuto; NDPicture *m_picAutoCancel; NDUIButton *m_btnAuto;

	//HighlightTip* m_highlightTip;

	bool m_bSendCurTurnUserAction;

	BATTLE_GROUP m_ourGroup;
	int m_orignalMapId;
	CGPoint m_orignalPos;
	NDMapLayer* m_mapLayer;
	int m_turn;
	int m_startWait;
	//ImageNumber* m_imgTurn;
//	NDUILabel* m_lbTurnTitle;
//	NDUILabel* m_lbTurn;

	int m_timeLeft;
	int m_timeLeftMax;
	int m_autoCount;
	int m_teamAmout;
	//ImageNumber* m_imgTimer;
//	NDUILabel* m_lbTimerTitle;
//	NDUILabel* m_lbTimer;

	//NDUILabel* m_lbAuto;
	//ImageNumber* m_imgAutoCount;
	NDTimer m_timer;
//	NDPicture* m_picWhoAmI;
//	NDPicture* m_picLingPai;
//	NDUIImage* m_imgWhoAmI;

	NDPicture* m_picActionWordDef;
	NDPicture* m_picActionWordDodge;
	NDPicture* m_picActionWordFlee;

//	NDUIImage* m_imgQuickTalkBg;
//	NDUITableLayer* m_tlQuickTalk;
	//NDUITableLayer* m_battleOpt;
	//NDUITableLayer* m_eudemonOpt;

	//NDUITableLayer* m_itemOpt;
	//NDUITableLayer* m_skillOpt;

	BATTLE_STATUS m_battleStatus;

	Fighter* m_highlightFighter;

	VEC_COMMAND m_vCmdList;

	int m_currentActionIndex1;	//1队当前战斗指令序列
	int m_currentActionIndex2;	//2队当前战斗指令序列
	int m_currentActionIndex3;	//3队当前战斗指令序列

	VEC_FIGHTER m_vActionFighterList;

	int m_actionFighterPoint;
	int m_foreBattleStatus;

	BATTLE_TYPE m_battleType;

	bool watchBattle;

	NDPicture* m_picBaoJi;
//	NDPicture* m_picBoji;

	BATTLE_COMPLETE battleCompleteResult;

	int serverBattleResult;	// 服务器返回的战斗结果

	NDUIDialog* m_dlgBattleResult;
	//NDUIDialog* m_dlgHint; // 提示对话框
	StatusDialog* m_dlgStatus;

	bool bActionSet;

	BattleAction* m_curBattleAction;

	// 每回合可用技能
	SET_BATTLE_SKILL_LIST m_setBattleSkillList;

	string m_rewardContent; // 战斗结果

	VEC_SUB_ANI_GROUP m_vSubAniGroup; // 技能子动画

	NDUILayer* m_battleBg;

//	PlayerHead* m_playerHead;
//	PetHead* m_petHead;

	bool m_bWatch; // 是否观战

	TEAM_STATUS m_Team1_status;
	TEAM_STATUS m_Team2_status;
	TEAM_STATUS m_Team3_status;

	int sceneMapId;
	int sceneCenterX;
	int sceneCenterY;
	//NDUIButton* m_btnCancleAutoFight;

private:
	void CloseChatInput();

	void Init();
	void addSkillEffectToFighter(Fighter* fighter, NDAnimationGroup* effect,
			int delay);
	void battleRefresh();

	bool sideRightAtk();

	void drawFighter();

	void OnBtnAttack();
	void OnBtnRun();
	void OnBtnDefence();
	void OnBtnCatch();
	void OnBtnAuto(bool bSendAction);
	//void OnBtnUseItem(BATTLE_STATUS bs);
	//void OnBtnSkill();

	void OnEudemonAttack();
	//void OnEudemonSkill();

	//void CloseItemMenu();
	void CloseViewStatus();
	//void CloseSkillMenu();

	void SetAutoCount();

	void dealWithFighterCmd(FIGHTER_CMD* cmd);

	void HighlightFighter(Fighter* f);

	Fighter* GetTouchedFighter(VEC_FIGHTER& fighterList, CGPoint pt);

	void SendBattleAction(const BattleAction& action);

	void ReleaseCommandList();

	Fighter* GetFighter(int idFighter);

	void AddAnActionFighter(Fighter* fAction);

	void ShowFight();

	void ShowPas();

	bool AllFighterActionOK();

	bool fighterStatusOK(VEC_FIGHTER& fighterList);

	void notifyNextFighterBeginAction();

	void moveToTarget(FightAction* action);
	void moveTeam(FightAction* action);
	void normalAttack(FightAction* action);
	void moveBack(FightAction* action);
	void aimTarget(FightAction* action);
	void normalDistanceAttack(FightAction* action);
	void distanceAttackOver(FightAction* action);
	void skillAttack(FightAction* action);
	void distanceSkillAttack(FightAction* theActor);
	void fighterSomeActionChangeToWait(VEC_FIGHTER& fighterList);

	void drawFighterHurt(VEC_FIGHTER& fighterList);
	void drawAllFighterHurtNumber();
	bool isPasClear();
	BATTLE_COMPLETE battleComplete();
	bool noOneCanAct(VEC_FIGHTER& fighterList);
	VEC_FIGHTER& GetOurSideList();
	VEC_FIGHTER& GetEnemySideList();
	void setFighterToWait(VEC_FIGHTER& fighterList);
	void setAllFightersToWait();
	void clearActionFighterStatus();
	void clearFighterStatus(Fighter& f);
	void performStatus(Fighter& theTarget);
	bool sideAttakerAtk();
	void showBattleComplete();
	void fleeSuccess(Fighter& theActor);
	void fleeFail(Fighter& theActor);
	void defence(Fighter& theActor);
	void catchPet(Fighter& f);
	void stopAuto();
	void useItem(Fighter& theActor);
	void setWillBeAtk(VEC_FIGHTER& fighterList);
	void clearAllWillBeAtk();
	void clearWillBeAtk(VEC_FIGHTER& fighterList);
	Fighter* getUpNearFighter(VEC_FIGHTER& fighterList, Fighter* f);
	Fighter* getFighterByPos(VEC_FIGHTER& fighterList, int pos, int line);
	Fighter* getDownNearFighter(VEC_FIGHTER& fighterList, Fighter* f);
	VEC_FIGHTER& getHighlightList();
	void clearHighlight();
	void handleStatusActions(VEC_STATUS_ACTION& statusActions);
	void addSkillEffect(Fighter& theActor, bool user = false);
	void sortFighterList(VEC_FIGHTER& fighterList);
	void startAction(FightAction* pkFighterAction);
	VEC_FIGHTER& getDefFightersByTeam(int team);
	void runAction(int nTeamID);
	bool isActionCanBegin(FightAction* action);
//	void CreateCancleAutoFightButton();
//	void RemoveCancleAutoFightButton();

	CAutoLink<NDEraseInOutEffect> eraseInOutEffect;
public:
	void StartEraseInEffect()
	{
		if (eraseInOutEffect)
			eraseInOutEffect->StartEraseIn();
	}
	void StartEraseOutEffect()
	{
		if (eraseInOutEffect)
			eraseInOutEffect->StartEraseOut();
	}
	bool IsEraseInOutEffectComplete()
	{
		if (eraseInOutEffect)
			return eraseInOutEffect->isChangeComplete();
		return true;
	}
	void CloseStatusDlg()
	{
		if (m_dlgStatus)
		{
			m_dlgStatus->RemoveFromParent(true);
			m_dlgStatus = NULL;
		}
	}
	void TurnStart();
	void TurnStartPet();
	int GetCurrentShowFighterId()
	{
		return currentShowFighter;
	}
	CoolDownRecord& GetSkillCoolDownRecord()
	{
		return m_recordCoolDown;
	}
private:
	// 战斗快捷栏
//	FighterBottom			*m_fighterBottom;
//	FighterLeft				*m_fighterLeft;
//	FighterRight				*m_fighterRight;

	//ChatTextFieldDelegate *m_chatDelegate;
	bool m_bShowChatTextField;
	bool m_bChatTextFieldShouldShow;
//	NDUIImage* m_imgChat;
//	NDUIButton* m_btnSendChat;
//	
//	NDUIImage* m_imgTurn;
//	NDUIImage* m_imgTimer;

	bool m_bShrinkRight;
	bool m_bShrinkLeft;
	bool m_bShrinkBottom;

	CoolDownRecord m_recordCoolDown;

	void RefreshItemBar();
	void RefreshSkillBar();
	void RefreshSkillBarPet();
	//void OnNDUISpeedBarEvent(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info, bool focused); override
	//void OnNDUISpeedBarSet(NDUISpeedBar* speedbar); override
	//void OnNDUISpeedBarShrinkClick(NDUISpeedBar* speedbar, bool fromShrnk); override
	//void OnRefreshFinish(NDUISpeedBar* speedbar, unsigned int page); override
	//void OnNDUISpeedBarEventLongTouch(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info); override
	void OnItemConfigFinish();

	bool IsUserOperating();
	bool IsEudemonOperating();
	void ShowTimerAndTurn(bool bShow);

	void ShowChatTextField(bool bShow);
	void ShowQuickChat(bool bShow);

	void UseSkillDealOfCooldown(int skillID);

	void AddTurnDealOfCooldown();
};

class QuickTalkCell: public NDUINode
{
	DECLARE_CLASS (QuickTalkCell)
public:
	QuickTalkCell();
	~QuickTalkCell();

	void Initialization(const char* pszText, const CGSize& size);

	void draw();

	string GetText();

private:
	NDUILabel* m_lbText;
	cocos2d::ccColor4B m_clrFocus;			// 焦点背景色
	cocos2d::ccColor4B m_clrText;
	cocos2d::ccColor4B m_clrFocusText;		// 焦点文本色
};

#endif
