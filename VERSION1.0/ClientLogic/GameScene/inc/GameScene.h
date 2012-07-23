/*
 *  GameScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-29.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _GAME_SCENE_H_
#define _GAME_SCENE_H_

#include "NDScene.h"
#include "NDMapLayerLogic.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
//#include "GameUIRootOperation.h"
#include "NDUIBaseGraphics.h"
#include "NDManualRole.h"
#include "define.h"
#include "NDUIDialog.h"
#include "NDTimer.h"
#include "NDUILabel.h"
#include <deque>
#include "ItemMgr.h"
//#include "Chat.h"
//#include "PlayerHead.h"
//#include "NDUICustomView.h"
#include <deque>
//#include "DirectKey.h"
#include "NDDirector.h"
#include "PlayerHead.h"
#include "GameUIRootOperation.h"
#include "DirectKey.h"

class QuickItem;

class QuickInteraction;

class QuickFunc;

class QuickTeam;

class UserStateLayer;
class Task;
class NDMiniMap;
using namespace NDEngine;


///////////////////////////////////////////////

// 战斗中无需删除的layer都添加到这个层上
class MapUILayer : public NDUILayer {
	DECLARE_CLASS(MapUILayer)
};

class PosText;
typedef map<int, PosText*> MAP_POS_TEXT;
typedef MAP_POS_TEXT::iterator MAP_POS_TEXT_IT;

typedef struct _tagMarriageInfo
{
	std::string name;
	int			iId;
	_tagMarriageInfo(std::string name, int iId)
	{
		this->name		= name;
		this->iId		= iId;
	}
	_tagMarriageInfo()
	{
		this->iId		= 0;
	}
}MarriageInfo;

typedef std::vector<MarriageInfo>		vec_marriage;
typedef vec_marriage::iterator			vec_marriage_it;


class GameScene : 
public NDScene, 
public NDUITableLayerDelegate,
public NDUIButtonDelegate,
//public NDUIHControlContainerDelegate,
//public NDUIAniLayerDelegate,
public NDUIDialogDelegate,
//public NDUICustomViewDelegate,
public ITimerCallback
{
	DECLARE_CLASS(GameScene)
public:
	void processMsgLightEffect(NDTransData& data);
	
	GameScene();
	~GameScene();

	static GameScene* Scene();
	void Initialization(int mapID); hide 
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnButtonClick(NDUIButton* button); override
	bool OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer);
	//bool OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer); override
	//void OnClickNDUIAniLayer(NDUIAniLayer* anilayer);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	//bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnBattleBegin();
	void OnBattleEnd();
	
	void OnTimer(OBJID tag);
	
	//NDUIAniLayer* GetRequestAniLayer() const {
	//	return m_anilayerRequest;
	//}
	
	/*
		desc:邮件与请求列表动画刷新接口
		arg: 1. type:0->请求列表,1->邮箱
			 2.	bFlash:true->闪动, false->固定
	**/
	void flashAniLayer(int type, bool bFlash);
	
	void AddUIChild(NDNode* node);
	void AddUIChild(NDNode* node, int z);
	void AddUIChild(NDNode* node, int z, int tag);
	
	/*
		desc:隐藏共享的tablelayer
		ret: true->成功,false->失败
	**/
	bool HideTLShare();
	DirectKey* const GetDirectKey();
	void ShowMiniMap(bool bShow);
	void ShowPlayerHead(bool bShow);
	void ShowPetHead(bool bShow);
	void ShowDirectKey(bool bShow);
	
	void SetMiniMapVisible(bool bVisible);
	
	void ShowRelieve(bool bShow);
	
	void ShowPaiHang(const std::vector<std::string>& vec_str, const std::vector<int>& vec_id);
	
	CGSize GetSize();
	
	cocos2d::CCArray* GetSwitchs();
	
	void ShowNPCDialog(bool bShowLeaveBtn=true);
	
	void ShowTaskAwardItemOpt(Task* task);
	
	bool IsUIShow(){ return m_bUIShow; }
	
	void AddUserState(int idState, string& str);
	
	void DelUserState(int idState);
	
	void SetTargetHead(NDBaseRole* target);
	
	void RefreshQuickInterationBar(NDBaseRole* target);
	
	void PushWorldMapScene();
	
	static void SetWeaponBroken(bool bSet);
	
	static void SetDefBroken(bool bSet);
	
	static void SetRidePetBroken(bool bSet);
	
	//处理版本消息
	void processVersionMsg(const char* version, int flag, const char* url);
	
	//　场景中的非总是可视UI在显示时需要调用,在销毁或隐藏时也需要调用
	void SetUIShow(bool bShow);
	
	//DirectKey* const GetDirectKey();
	
	void HandleRootMenuAfterSceneLoad();
	
	void RefreshQuickItem();
	
	void ShrinkQuickInteraction();
	
	void ShrinkQuickItem();
	
	void TeamRefreh(bool newJoin);
	
	void processMsgPosText(NDTransData& data);
	
	void ShowShopAndRecharge();
	
	void ShowMarriageList(vec_marriage& vMarriage);
	
	void ShowTaskFinish(bool show, std::string tip);
private:
	void InitTLShareContent(std::vector<std::string>& vec_str);
	void InitTLShareContent(const char* text, ...);
	void InitContent(NDUITableLayer* tl, const std::vector<std::string>& vec_str, const std::vector<int>& vec_id);
	std::string GetTLShareSelText(NDUINode* uinode);
	void ReShowTaskAwardItemOpt();
	void onClickSyndicate();
	bool checkNewPwd(const string& pwd);
	void onClickTeam();
	
	NDMapLayerLogic *maplayer;
	
	//游戏场景中的总是可视UI定义..
	//NDUIHControlContainer		*m_hccOPItem;
	NDPicture		*m_picMap; NDUIButton *m_btnMap;
	NDPicture		*m_picTarget; NDUIButton *m_btnTarget;
	NDPicture		*m_picInterative; NDUIButton *m_btnInterative;
	
	//NDUIHControlContainer *m_hccOPMenu;
	NDPicture		*m_picTeam; NDUIButton *m_btnTeam;
	NDPicture		*m_picSocial; NDUIButton *m_btnSocial;
	NDPicture		*m_picTalk; NDUIButton *m_btnTalk;
	NDPicture		*m_picTask; NDUIButton *m_btnTask;
	NDPicture		*m_picBag; NDUIButton *m_btnBag;
	NDPicture		*m_picStore; NDUIButton *m_btnStore;
	NDPicture		*m_picMenu; NDUIButton *m_btnMenu;
	
	//NDUIAniLayer	*m_anilayerRequest, *m_anilayerMail;
	
	NDUITableLayer *m_tlShare;
	NDUITableLayer *m_tlInteractive;
	NDUITableLayer *m_tlInvitePlayers;
	NDUITableLayer *m_tlKickPlayers;
	NDUITableLayer *m_tlTiShengPlayers;
	NDUITableLayer *m_tlPaiHang;
	NDUITableLayer *m_tlMarriage;
	NDMiniMap *m_miniMap;
	//PlayerHeadInMap* m_playerHead;
	//PlayerHeadInMap* m_petHead;
	//TargetHeadInMap* m_targetHead;
	UserStateLayer* m_userState;
	//DirectKey *m_directKey;
	
	PlayerHeadInMap* m_playerHead;
	TargetHeadInMap* m_targetHead;
	DirectKey* m_directKey;
	NDUIHControlContainer* m_hccOPItem;
	PlayerHeadInMap* m_petHead;

	bool m_bQuickInterationShow;
	NDPicture* m_picQuickInteration; NDUIButton* m_btnQuickInterationShrink;
	QuickInteraction* m_quickInteration;
	
	QuickItem *m_quickItem;

	QuickFunc *m_quickFunc;

	QuickTeam *m_quickTeam;
	
	bool m_bHeadShow;
	NDUIImage* m_imgHeadShow;
	NDPicture* m_picHeadShow; NDUIButton* m_btnHeadShow;
	
	//NDUIDialog *m_dlgNPC;
	unsigned int m_dlgNPCTag;
	OBJID m_dlgTaskAwardItemTag;
	OBJID m_dlgTaskAwardItemConfirmTag;
	OBJID m_dlgSyndicateResign; // 军团辞职
	OBJID m_dlgSyndicateQuit; // 退出军团
	OBJID m_dlgDelRoleTag;
	uint m_curSelTaskAwardItemIndex;
	
	NDUIDialog *m_dlgFarm; // 庄园对话框
	
	NDUILayer *m_relieveLayer;
	NDUITableLayer *m_tlRelieve;
	
	MapUILayer* m_uiLayer;
	
	VEC_ITEM m_vTaskAwardItem;
	
	bool m_bUIShow;
	
	static bool bWeaponBroken, bDefBroken, bRidePetBroken;
	
	CGPoint m_playerPosWithMap;
	
	deque<int> m_stackUIMenu;
	
	std::string m_updateUrl;
	
	static GameScene* s_curGameScene;
	
	static MAP_POS_TEXT s_mapPosText;
	
	NDTimer m_timer;
	
public:
	static void ShowUIPaiHang();
	static void ShowShop(int iNPCID = 0);
	static GameScene* GetCurGameScene();
	static MAP_POS_TEXT& GetAllPosText() {
		return s_mapPosText;
	}
	static void ClearAllPosText() {
		s_mapPosText.clear();
	}
};


class GameSceneReleaseHelper : 
public NDObject
//public NDDirectorDelegate
{
	DECLARE_CLASS(GameSceneReleaseHelper)
public:
	~GameSceneReleaseHelper();
	
	static void Begin();
	static void End();
	
	void BeforeDirectorPopScene(NDDirector* director, NDScene* scene, bool cleanScene); override
	void AfterDirectorPopScene(NDDirector* director, bool cleanScene); override
private:
	GameSceneReleaseHelper();
	static GameSceneReleaseHelper* s_instance;
	bool m_bGameSceneRelease;
};

#endif // _GAME_SCENE_H_