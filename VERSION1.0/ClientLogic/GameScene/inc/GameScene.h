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

//class QuickFunc; ///< 临时性注释 郭浩

class QuickTeam;

//class UserStateLayer; ///< 临时性注释 郭浩
class Task;
//class NDMiniMap; ///< 临时性注释 郭浩
using namespace NDEngine;

///////////////////////////////////////////////

// 战斗中无霄1�7删除的layer都添加到这个层上
class MapUILayer: public NDUILayer
{
	DECLARE_CLASS (MapUILayer)
};

class PosText;
typedef map<int, PosText*> MAP_POS_TEXT;
typedef MAP_POS_TEXT::iterator MAP_POS_TEXT_IT;

typedef struct _tagMarriageInfo
{
	std::string name;
	int iId;
	_tagMarriageInfo(std::string name, int iId)
	{
		this->name = name;
		this->iId = iId;
	}
	_tagMarriageInfo()
	{
		this->iId = 0;
	}
} MarriageInfo;

typedef std::vector<MarriageInfo> vec_marriage;
typedef vec_marriage::iterator vec_marriage_it;

class GameScene: public NDScene,
//public NDUITableLayerDelegate, ///< 临时性注釄1�7 郭浩
		public NDUIButtonDelegate,
		//public NDUIHControlContainerDelegate,
		//public NDUIAniLayerDelegate,
		public NDUIDialogDelegate,
		//public NDUICustomViewDelegate,
		public ITimerCallback
{
	DECLARE_CLASS (GameScene)
public:

	CC_SYNTHESIZE(NDPlayer*,m_pkUpdatePlayer,UpdatePlayer);

	void processMsgLightEffect(NDTransData& data);

	GameScene();
	~GameScene();

	static GameScene* Scene();
	void Initialization(int mapID);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
			unsigned int cellIndex, NDSection* section);override
	void OnButtonClick(NDUIButton* button);override
	bool OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer);
	//bool OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer); override
	//void OnClickNDUIAniLayer(NDUIAniLayer* anilayer);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);override
	void OnDialogClose(NDUIDialog* dialog);override
	//bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnBattleBegin();
	void OnBattleEnd();

	void OnTimer(OBJID tag);

	//NDUIAniLayer* GetRequestAniLayer() const {
	//	return m_anilayerRequest;
	//}

	/*
	 desc:邮件与请求列表动画刷新接叄1�7
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
	//DirectKey* const GetDirectKey(); ///< 临时性注釄1�7 郭浩
	void ShowMiniMap(bool bShow);
	void ShowPlayerHead(bool bShow);
	void ShowPetHead(bool bShow);
	void ShowDirectKey(bool bShow);

	void SetMiniMapVisible(bool bVisible);

	void ShowRelieve(bool bShow);

	void ShowPaiHang(const std::vector<std::string>& vec_str,
			const std::vector<int>& vec_id);

	CGSize GetSize();

	cocos2d::CCArray* GetSwitchs();

	void ShowNPCDialog(bool bShowLeaveBtn = true);

	void ShowTaskAwardItemOpt(Task* task);

	bool IsUIShow()
	{
		return m_bUIShow;
	}

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

	//〄1�7场景中的非1愤7�是可视UI在显示时霄1�7要调甄1�7,在销毁或隐藏时也霄1�7要调甄1�7
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

	//add by ZhangDi 120904
	bool AddMonster(int nKey, int nLookFace);

	bool AddNpc(int nKey, int nLookFace);

	bool AddManuRole(int nKey, int nLookFace);

	NDManualRole* GetManuRole(int nKey);

	NDMonster* GetMonster(int nKey);

	NDNpc* GetNpc(int nKey);

	NDSprite* GetSprite(int nKey);
private:
	//add by ZhangDi 120904
	bool AddNodeToMap(NDNode* node);
	bool RemoveNodeFromMap(NDNode* node);

	bool RemoveNpcNode(NDNode* node);
	typedef std::map<int, NDManualRole*>					MAP_MANUROLE;
	typedef MAP_MANUROLE::iterator							MAP_MANUROLE_IT;

	typedef std::map<int, NDMonster*>						MAP_MONSTER;
	typedef MAP_MONSTER::iterator							MAP_MONSTER_IT;

	typedef std::map<int, NDNpc*>							MAP_NPC;
	typedef MAP_NPC::iterator								MAP_NPC_IT;

	typedef std::map<int, NDSprite*>						MAP_SPRITE;
	typedef MAP_SPRITE::iterator							MAP_SPRITE_IT;

	MAP_MANUROLE				m_mapManuRole;
	MAP_MONSTER					m_mapMonster;
	MAP_NPC						m_mapNpc;
	MAP_SPRITE					m_mapSprite;

	void InitTLShareContent(std::vector<std::string>& vec_str);
	void InitTLShareContent(const char* pszText, ...);
	void InitContent(NDUITableLayer* tl,
			const std::vector<std::string>& vec_str,
			const std::vector<int>& vec_id);
	std::string GetTLShareSelText(NDUINode* uinode);
	void ReShowTaskAwardItemOpt();
	void onClickSyndicate();
	bool checkNewPwd(const string& pwd);
	void onClickTeam();

	NDMapLayerLogic* m_pkMapLayerLogic;

	//游戏场景中的总是可视UI定义..
	//NDUIHControlContainer		*m_hccOPItem;
	NDPicture *m_picMap;
	NDUIButton *m_btnMap;
	NDPicture *m_picTarget;
	NDUIButton *m_btnTarget;
	NDPicture *m_picInterative;
	NDUIButton *m_btnInterative;

	//NDUIHControlContainer *m_hccOPMenu;
	NDPicture *m_picTeam;
	NDUIButton *m_btnTeam;
	NDPicture *m_picSocial;
	NDUIButton *m_btnSocial;
	NDPicture *m_picTalk;
	NDUIButton *m_btnTalk;
	NDPicture *m_picTask;
	NDUIButton *m_btnTask;
	NDPicture *m_picBag;
	NDUIButton *m_btnBag;
	NDPicture *m_picStore;
	NDUIButton *m_btnStore;
	NDPicture *m_picMenu;
	NDUIButton *m_btnMenu;

	//NDUIAniLayer	*m_anilayerRequest, *m_anilayerMail;

	NDUITableLayer *m_tlShare;
	NDUITableLayer *m_tlInteractive;
	NDUITableLayer *m_tlInvitePlayers;
	NDUITableLayer *m_tlKickPlayers;
	NDUITableLayer *m_tlTiShengPlayers;
	NDUITableLayer *m_tlPaiHang;
	NDUITableLayer *m_tlMarriage;
	//NDMiniMap *m_miniMap; ///< 临时性注釄1�7 郭浩

	/***
	 * 临时性注釄1�7 郭浩
	 * begin
	 */
	//PlayerHeadInMap* m_playerHead;
	//PlayerHeadInMap* m_petHead;
	//TargetHeadInMap* m_targetHead;
//	UserStateLayer* m_userState;
	//DirectKey *m_directKey;
	/***
	 * 临时性注釄1�7 郭浩
	 * end
	 */

	//PlayerHeadInMap* m_playerHead; ///< 临时性注釄1�7 郭浩
//	TargetHeadInMap* m_targetHead; ///< 临时性注釄1�7 郭浩
//	DirectKey* m_directKey; ///< 临时性注釄1�7 郭浩
	NDUIHControlContainer* m_hccOPItem;
	//PlayerHeadInMap* m_petHead; ///< 临时性注釄1�7 郭浩

	bool m_bQuickInterationShow;
	NDPicture* m_picQuickInteration;
	NDUIButton* m_btnQuickInterationShrink;
	QuickInteraction* m_quickInteration;

	QuickItem *m_quickItem;

	//QuickFunc *m_quickFunc; ///< 临时性注釄1�7 郭浩

	QuickTeam *m_quickTeam;

	bool m_bHeadShow;
	NDUIImage* m_pkHeadShowImage;
	NDPicture* m_picHeadShow;
	NDUIButton* m_btnHeadShow;

	//NDUIDialog *m_dlgNPC;
	unsigned int m_uiNPCTagDialog;
	OBJID m_dlgTaskAwardItemTag;
	OBJID m_dlgTaskAwardItemConfirmTag;
	OBJID m_dlgSyndicateResign; // 军团辞职
	OBJID m_dlgSyndicateQuit; // 逄1�7出军囄1�7
	OBJID m_dlgDelRoleTag;
	uint m_curSelTaskAwardItemIndex;

	NDUIDialog *m_dlgFarm; // 庄园对话桄1�7

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
	static MAP_POS_TEXT& GetAllPosText()
	{
		return s_mapPosText;
	}
	static void ClearAllPosText()
	{
		s_mapPosText.clear();
	}
};

class GameSceneReleaseHelper: public NDObject
//public NDDirectorDelegate
{
	DECLARE_CLASS (GameSceneReleaseHelper)
public:
	~GameSceneReleaseHelper();

	static void Begin();
	static void End();

	void BeforeDirectorPopScene(NDDirector* director, NDScene* scene,
			bool cleanScene);override
	void AfterDirectorPopScene(NDDirector* director, bool cleanScene);override
private:
	GameSceneReleaseHelper();
	static GameSceneReleaseHelper* s_instance;
	bool m_bGameSceneRelease;
};

#endif // _GAME_SCENE_H_
