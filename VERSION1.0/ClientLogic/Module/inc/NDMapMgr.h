/*
*
*/

#ifndef NDMAPMGR_H
#define NDMAPMGR_H

#include <vector>
#include <string>
#include <map>
#include "NDObject.h"
#include "GatherPoint.h"
#include "FriendElement.h"
#include "NDScene.h"
#include "NDManualRole.h"
#include "NDTransData.h"
#include "NDMonster.h"
#include "NDNpc.h"
#include "NDBaseRole.h"
#include "NDUICustomView.h"
#include "NDMapLayer.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "NDConsole.h"
#endif
#include "NDTimer.h"
#include "AutoLink.h"
//#include "GameUIRequest.h"		///< 依赖汤自勤的GameUIRequest
#include "GlobalDialog.h"
#ifdef USE_MGSDK
#import "MBGPlatform.h"
#endif

using namespace std;

#define NDMapMgrObj NDEngine::NDMapMgr::GetSingleton()
#define NDMapMgrPtr NDEngine::NDMapMgr::GetSingletonPtr()

namespace NDEngine
{

class NDBaseRole;
class NDNpc;
class NDMonster;
class NDTransData;
class NDManualRole;
class NDScene;

enum 
{
	// battlelistener
	REHEARSE_APPLY = 0, // 申请
	REHEARSE_ACCEPT = 1, // 接受
	REHEARSE_REFUSE = 2, // 拒绝
	REHEARSE_LOGOUT = 3, // 战斗内离线
	REHEARSE_LOGIN = 4, // 战斗内断线重连

	// baselistener
	_SEE_USER_INFO = 0, // 查看玩家信息
	SEE_EQUIP_INFO = 1, // 查看玩家装备
	SEE_PET_INFO = 3, // 查看玩家宠物
};

enum 
{
	_FRIEND_APPLY = 10,// 请求添加好友:客户端发上来的只带Name，
	// 服务器发出去的消息应该附上ID
	_FRIEND_ACCEPT = 11, // 同意添加好友:客户端发上来的只带ID，服务器发出去的消息应该附上Name
	_FRIEND_ONLINE = 12, // 通知其在线好友本玩家上线了
	_FRIEND_OFFLINE = 13,// 通知其在线好友本玩家下线了
	_FRIEND_BREAK = 14,// 删除好友
	_FRIEND_GETINFO = 15,// 发送好友信息 //OBJID idFriend, bool bOnline, const
	// char* pszName
	_FRIEND_REFUSE = 16,// 拒绝添加好友:客户端发上来的只带ID，服务器发出去的消息应该附上Name
	_FRIEND_DELROLE = 17,// 玩家删除角色
};

enum
{
	MONSTER_INFO_ACT_INFO,				//怪物类型信息
	MONSTER_INFO_ACT_POS,				//怪物位置
	MONSTER_INFO_ACT_STATE,				//更新怪物状态
	MONSTER_INFO_ACT_BOSS_POS,			//BOSS位置
	MONSTER_INFO_ACT_BOSS_STATE,		//更新BOSS状态
};

enum 
{
	MSG_TEAM_CREATE = 7758,

	MSG_TEAM_DISMISS = 7759,

	MSG_TEAM_DISMISSFAILE = 7760,

	MSG_TEAM_JOIN = 7761,

	MSG_TEAM_JOINOK = 7762,

	MSG_TEAM_JOINFAILE = 7763,

	MSG_TEAM_KICK = 7764,

	MSG_TEAM_KICKOK = 7765,

	MSG_TEAM_KICKFAILE = 7766,

	MSG_TEAM_INVITE = 7767,

	MSG_TEAM_INVITEOK = 7768,

	MSG_TEAM_INVITEFAILE = 7769,

	MSG_TEAM_LEAVE = 7770,

	MSG_TEAM_ENABLEACCEPT = 7771,

	MSG_TEAM_DISABLEACCEPT = 7772,

	MSG_TEAM_CHGLEADER = 7773,

	MSG_TEAM_TEAMID = 7774,
};

enum  
{
	eTeamLen = 5,
	MAX_FRIEND_NUM = 20,
};

// 仓库相关
enum  
{
	MSG_STORAGE_MONEY_SAVE = 1 ,

	MSG_STORAGE_MONEY_DRAW = 2 ,

	MSG_STORAGE_MONEY_QUERY = 3 ,

	MSG_STORAGE_ITEM_IN = 4 ,

	MSG_STORAGE_ITEM_OUT = 5 ,

	MSG_STORAGE_ITEM_QUERY = 6 ,

	MSG_STORAGE_EMONEY_SAVE = 7 ,

	MSG_STORAGE_EMONEY_DRAW = 8 ,

	MSG_STORAGE_EMONEY_QUERY = 9 ,
};

// 对话后customview操作
enum  
{
	eCVOP_GiftNPC = 300,
	eCVOP_Wish,
	eCVOP_FarmName,
	eCVOP_FarmWelcomeName,
	eCVOP_FarmBuildingName,
	eCVOP_FarmHarmletName,
};
enum  
{
	KEY_LENGTH = 10, // 礼包序列号长度
};

enum  
{
	_MARRIAGE_APPLY = 1, // 结婚申请
	_MARRIAGE_AGREE = 2, // 同意结婚
	_MARRIAGE_REFUSE = 3, // 拒绝结婚
	_DIVORCE_APPLY = 4, // 离婚申请
	_DIVORCE_AGREE = 5, // 同意离婚
	_MARRIAGE_QUARY = 6, // 下达配偶ID
	_MARRIAGE_MATE_LOGIN = 7, // 配偶上线
	_MARRIAGE_MATE_ONLINE = 8, // 配偶在线
	_MARRIAGE_MATE_LOGOUT = 9, // 配偶下线
};

enum
{
	RECHARGE_RETURN_ACT_QUERY			= 0,	// 充值说明
	RECHARGE_RETURN_ACT_TRUE			= 1,	// 充值成功	
	RECHARGE_RETURN_ACT_FALSE			= 2,	// 充值失败
	RECHARGE_RETURN_ACT_QUERY_RECORD	= 3,	// 充值记录
};

//////////////////////////////////
int getShengWangLevel(int v);
int getDiscount(int v);

struct s_team_info
{
	int team[eTeamLen];
	s_team_info() { memset(this, 0, sizeof(*this)); }
};


typedef struct _STRU_MONSTER_TYPE_INFO
{
	int idType;
	int lookFace;
	unsigned char  lev;
	unsigned char  btAiType;
	unsigned char  btCamp;
	unsigned char  btAtkArea;
	string		   name;

	_STRU_MONSTER_TYPE_INFO()
	{
		idType			= 0;
		lookFace		= 0;
		lev				= 0;
		btAiType		= 0;
		btCamp			= 0;
		btAtkArea		= 0;
		name			= "";
	}

	void operator = (_STRU_MONSTER_TYPE_INFO & other)
	{
		if (this == &other)
		{
			return;
		}
		idType			= other.idType;
		lookFace		= other.lookFace;
		lev				= other.lev;
		btAiType		= other.btAiType;
		btCamp			= other.btCamp;
		btAtkArea		= other.btAtkArea;
		name			= other.name;
	}

}monster_type_info;

typedef map<int,monster_type_info>			monster_info;
typedef monster_info::iterator				monster_info_it;
typedef pair<int, monster_type_info>		monster_info_pair;

typedef map<int,GatherPoint*>				map_gather_point;
typedef map_gather_point::iterator			map_gather_point_it;
typedef pair<int, GatherPoint*>				map_gather_point_pair;

typedef map<int, FriendElement>			MAP_FRIEND_ELEMENT;
typedef MAP_FRIEND_ELEMENT::iterator		MAP_FRIEND_ELEMENT_IT;


typedef struct _tagShopItemInfo 
{
	int itemType;
	int payType;
	_tagShopItemInfo() { memset(this, 0, sizeof(*this)); }
	_tagShopItemInfo(int itemType, int payType)
	{
		itemType = itemType;
		payType = payType;
	}
}ShopItemInfo;

typedef map<int ,vector<ShopItemInfo> >		map_npc_store;
typedef map_npc_store::iterator				map_npc_store_it;
typedef pair<int, vector<ShopItemInfo> >	map_npc_store_pair;

// npc技能学习
typedef vector<int> VEC_BATTLE_SKILL;
typedef VEC_BATTLE_SKILL::iterator VEC_BATTLE_SKILL_IT;

typedef map<int ,vector<ShopItemInfo> >		map_npc_store;
typedef map_npc_store::iterator				map_npc_store_it;

// 邮件
//typedef vector<EmailData*>	vec_email;
//typedef vec_email::iterator	vec_email_it;

class NDMapMgr:
	public NDObject,
	public TSingleton<NDMapMgr>,
	public NDMsgObject,
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	public NDConsoleListener,
#endif
	public ITimerCallback
{
public:
	DECLARE_CLASS(NDMapMgr);
	NDMapMgr();
	virtual ~NDMapMgr();




public:
	typedef vector<NDNpc*> VEC_NPC;
	typedef vector<NDMonster*> VEC_MONSTER;
	typedef VEC_NPC::iterator vec_npc_it;
	typedef VEC_MONSTER::iterator vec_monster_it;
	typedef map<int,NDManualRole*> map_manualrole;
	typedef map_manualrole::iterator map_manualrole_it;
	typedef pair<int,NDManualRole*> map_manualrole_pair;

	//typedef vector<RequsetInfo> VEC_REQUST; ///< 依赖汤自勤的GameUIRequest 郭浩




	virtual void Update(unsigned long ulDiff);
	NDMonster* GetMonster(int nID);

	bool isMonsterClear();

	bool canChangeMap()
	{
		return (mapType & MAPTYPE_CHGMAP_DISABLE) == 0;
	}

	bool canRecord()
	{
		return (mapType & MAPTYPE_RECORD_DISABLE) == 0;
	}

	bool canPk()
	{
		return (mapType & MAPTYPE_PK_DISABLE) == 0;
	}

	bool canBooth()
	{
		return (mapType & MAPTYPE_BOOTH_ENABLE) > 0;
	}

	bool canBattle()
	{
		return (mapType & MAPTYPE_BATTLE_DISABLE) == 0;
	}

	bool canFly()
	{
		return false;
	}

	NDManualRole* NearestDacoityManualrole(NDManualRole& role, int iDis);
	NDManualRole* NearestBattleFieldManualrole(NDManualRole& role, int iDis);
	int getDistBetweenRole(NDBaseRole *firstrole, NDBaseRole *secondrole);

	virtual bool process( MSGID usMsgID, NDEngine::NDTransData* pkData, int nLength );
	void processMsgCommonList(NDTransData& kData);
	void processSee(NDTransData& kData);
	void processNPCInfo(NDTransData& kData);
	void processGameQuit(NDTransData* pkData,int nLength);
	void processMsgCommonListRecord(NDTransData& kData);
	void processNpcPosition(NDTransData& kData);
	void processPlayer(NDTransData* pkData,int nLength);
	void processPlayerExt(NDTransData* pkData,int nLength);
	void processWalk(NDTransData* pkData,int nLength);
	void processWalkTo(NDTransData& kData);
	void processTalk(NDTransData& kData);
	void processNpcTalk(NDTransData& kData);
	void ProcessLoginSuc(NDTransData& kData);
	void processCompetition(NDTransData& kData);
	void processShowTreasureHuntAward(NDTransData& kData);
	void processRespondTreasureHuntProb(NDTransData& kData);
	void processMsgDlg(NDTransData& kData);
	void processRespondTreasureHuntInfo(NDTransData& kData);
	void processKickOutTip(NDTransData& kData);
	void processItemTypeInfo(NDTransData& kData);
	void processReCharge(NDTransData& kData);
	void processGoodFriend(NDTransData& kData);
	void processRechargeReturn(NDTransData& kData);
	void processVersionMsg(NDTransData& kData);
	void processQueryPetSkill(NDTransData& kData);
	void processRoadBlock(NDTransData& kData);
	void ProcessTempCredential(NDTransData& kData);
	void processChangeRoom(NDTransData* pkData,int nLength);
	void processActivity(NDTransData& kData);
	void processPortal(NDTransData& kData);
	void processMarriage(NDTransData& kData);
	void processDeleteRole(NDTransData& kData);
	void processNPCInfoList(NDTransData* pkData,int nLength);
	void processKickBack(NDTransData* pkData,int nLength);
	void processChgPoint(NDTransData* pkData,int nLength);
	void processCollection(NDTransData& kData);
	void processUserInfoSee(NDTransData& kData);
	void processPlayerLevelUp(NDTransData& kData);
	void processShopInfo(NDTransData& data);
	void processNPC(NDTransData& kData);
	void processPetInfo(NDTransData* pkData,int nLength);
	void processMonsterInfo(NDTransData* pkData, int nLength);
	void processNpcStatus(NDTransData* pkData, int nLength);
	void processFormula(NDTransData& kData);
	void processRehearse(NDTransData& kData);
	void processDigout(NDTransData& kData);
	void processDisappear(NDTransData* pkData, int nLength);
	void processSyndicate(NDTransData& kData);
	void BattleStart();
	void BattleEnd(int iResult);
	void throughMap(int mapX, int mapY, int mapId);
	//void addRequst(RequsetInfo& request);		///< RequestInfo需要合并后 郭浩
	void NavigateToNpc(int nNpcId);
    void ProcessOAuthTokenRet(NDTransData& data);
    void ProcessCreateTransactionRet(NDTransData& data);
    void ProcessCloseTransactionRet(NDTransData& data);
    void sendVerifier(CCString *verifier);
    
#ifdef USE_MGSDK
    void VerifierError(MBGError *error);
    void CloseTransaction();
    void CancelTransaction();
    void TransactionError(MBGError *error);
#endif
	void RegisProcessMsg();
public:

	bool Hack_loadSceneByMapDocID(int nMapID) { return loadSceneByMapDocID(nMapID); }; //for debug purpose only.
	NDBaseRole* GetNextTarget(int iDistance);
	NDBaseRole* GetRoleNearstPlayer(int iDistance);
	
public:
	typedef map<int/*idNpc*/, VEC_BATTLE_SKILL> MAP_NPC_SKILL_STORE;
	typedef MAP_NPC_SKILL_STORE::iterator MAP_NPC_SKILL_STORE_IT;

	MAP_NPC_SKILL_STORE m_mapNpcSkillStore;
	void LoadSceneMonster();
	void AddManualRole(int nID,NDManualRole* pkRole);
	NDManualRole* GetManualRole(int nID);
	NDManualRole* GetManualRole(const char* pszName);
	map_manualrole& GetManualRoles() { return m_mapManualRole; }
	void ClearManualRole();
	void AddAllNPCToMap();
	NDMonster* GetBoss();
	void AddAllMonsterToMap();
	bool GetMonsterInfo(monster_type_info& kInfo, int nType);
	void DelManualRole(int nID);
	void ClearNPC();
	NDNpc* GetNpc(int nID);
	void ClearMonster();
	void setNpcTaskStateById(int nNPCID,int nState);
	//void addRequst(RequsetInfo& kRequest);	///< 依赖汤自勤的RequsetInfo 郭浩
	void DelNpc(int nID);
	void AddOneNPC(NDNpc* pkNpc);
	bool DelRequest(int nID);
	void ClearGP();
	bool loadSceneByMapDocID(int nMapID);
	void AddSwitch();
	int GetMapID();
	int GetMotherMapID();
	//LifeSkill* getLifeSkill(OBJID idSkill);
	std::vector<NDManualRole*> GetPlayerTeamList();

	string changeNpcString(string str);
	void WorldMapSwitch(int mapId);  //世界地图中地图切换
	NDNpc* GetNpcByID(int nID);
	void ClearNPCChat();
	NDMapLayer* getMapLayerOfScene(NDScene* pkScene);

	virtual void OnCustomViewRadioButtonSelected( NDUICustomView* customView,
		unsigned int radioButtonIndex, int ortherButtonTag );

	virtual bool processConsole( const char* pszInput );
	virtual bool processPM(const char* pszCmd) { return true; }

	virtual void OnTimer( OBJID tag );
	virtual NDMonster* GetBattleMonster();
	void SetBattleMonster(NDMonster* pkMonster);

	CC_SYNTHESIZE(int,m_nCurrentMonsterRound,CurrentMonsterRound);		///< 貌似此变量没有什么引用，废弃掉？ 郭浩
    int GetCurrentMonsterRound(){return m_nCurrentMonsterRound;}

	static bool m_bFirstCreate;
	static bool m_bVerifyVersion;

	int m_iCurDlgNpcID;

	int zhengYing[CAMP_TYPE_END];

	map_manualrole m_mapManualRole;
	monster_info m_mapMonsterInfo;
	map_npc_store m_mapNpcStore;
	VEC_NPC m_vNPC;
	VEC_MONSTER m_vMonster;

	NDTimer m_kTimer;

	int m_nCurrentMonsterBound;
	int m_nRoadBlockX;
	int m_nRoadBlockY;
	int m_nMapType;
	int m_nSaveMapID;
	int m_nMapID;
	int m_nMapDocID;
	int mapType;

	OBJID m_idTradeDlg;
	OBJID m_idAuctionDlg;
	OBJID m_idDeMarry;
	OBJID m_idDialogDemarry;
	OBJID m_idDialogMarry;

	bool isShowName;
	bool isShowOther;

	CCSize m_kMapSize;

	struct st_npc_op
	{
		int idx; string str; bool bArrow;
		st_npc_op() { bArrow = false; }
	};

	string m_strMapName;
	/**npc聊天相关*/
	unsigned short usData;
	string strLeaveMsg;
	string strTitle;
	string strNPCText;
	string m_strNoteTitle; // 公告
	string m_strNoteContent;

	vector<st_npc_op> vecNPCOPText;

	CAutoLink<NDMonster> m_apWaitBattleMonster;
//	VEC_REQUST m_vecRequest;		///< 依赖汤自勤的GameUIRequest 郭浩
	CIDFactory m_idAlloc;

private:
};

}

#endif