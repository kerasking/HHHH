#include "Singleton.h"
#include "define.h"
#include <vector>
#include <string>
#include <map>
#include "NDMapLayer.h"
#include "NDNetMsg.h"
#include "GlobalDialog.h"
#include "NDTimer.h"
#include "SMBattleScene.h"
#include "EnumDef.h"

using namespace std;

#define NDMapMgrObj NDEngine::NDMapMgr::GetSingleton()
#define NDMapMgrPtr	NDEngine::NDMapMgr::GetSingletonPtr()

class EmailData;
class BattleSkill;
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
		REHEARSE_APPLY = 0, // 申请
		REHEARSE_ACCEPT = 1, // 接受
		REHEARSE_REFUSE = 2, // 拒绝
		REHEARSE_LOGOUT = 3, // 战斗内离线
		REHEARSE_LOGIN = 4, // 战斗内断线重连

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
	
	enum  {
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
	
	//typedef map<int,GatherPoint*>				map_gather_point;
	//typedef map_gather_point::iterator			map_gather_point_it;
	//typedef pair<int, GatherPoint*>				map_gather_point_pair;
	
	//typedef map<int, FriendElement>			MAP_FRIEND_ELEMENT;
	//typedef MAP_FRIEND_ELEMENT::iterator		MAP_FRIEND_ELEMENT_IT;
	
	
	typedef struct _tagShopItemInfo 
	{
		int itemType, payType;
		_tagShopItemInfo() { memset(this, 0, sizeof(*this)); }
		_tagShopItemInfo(int itemType, int payType)
		{
			this->itemType = itemType;
			this->payType = payType;
		}
	}ShopItemInfo;
	
	typedef map<int ,vector<ShopItemInfo> >		map_npc_store;
	typedef map_npc_store::iterator				map_npc_store_it;
	typedef pair<int, vector<ShopItemInfo> >	map_npc_store_pair;
	
	// npc技能学习
	typedef vector<int> VEC_BATTLE_SKILL;
	typedef VEC_BATTLE_SKILL::iterator VEC_BATTLE_SKILL_IT;
	
	// 邮件
	typedef vector<EmailData*>	vec_email;
	typedef vec_email::iterator	vec_email_it;
	
	// 全局数据管理类 + 消息处理
	class NDMapMgr :
	public TSingleton<NDMapMgr>,
	public NDMsgObject,
	public NDObject,
	public NDUIDialogDelegate
	//public NDUICustomViewDelegate
	{
		DECLARE_CLASS(NDMapMgr)
	public:
		NDMapMgr();
		~NDMapMgr();
		
		void Update(unsigned long ulDiff);
		
		typedef vector<NDNpc*> VEC_NPC;
		typedef vector<NDMonster*> VEC_MONSTER;
		typedef VEC_NPC::iterator vec_npc_it;
		typedef VEC_MONSTER::iterator vec_monster_it;
		typedef map<int, NDManualRole*> map_manualrole;
		typedef map_manualrole::iterator map_manualrole_it;
		typedef pair<int, NDManualRole*> map_manualrole_pair;
		
		//typedef map<OBJID, LifeSkill> MAP_LEARNED_LIFE_SKILL;
		//typedef MAP_LEARNED_LIFE_SKILL::iterator MAP_LEARNED_LIFE_SKILL_IT;
		
		//typedef map<int,FormulaMaterialData*>		map_fomula;
		//typedef map_fomula::iterator				map_fomula_it;
		//typedef pair<int,FormulaMaterialData*>		map_fomula_pair;
		
		virtual void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
		void OnDialogClose(NDUIDialog* dialog); override
		//bool OnCustomViewConfirm(NDUICustomView* customView); override
		/*处理感兴趣的网络消息*/
		bool process(MSGID msgID, NDTransData* data, int len); override	
		void processUserInfo(NDTransData* data, int len);
		void processUserAttrib(NDTransData* data, int len);
		void processChangeRoom(NDTransData* data, int len);
		void processPlayer(NDTransData* data, int len);
		void processPlayerExt(NDTransData* data, int len);
		void processWalk(NDTransData* data, int len);
		void processKickBack(NDTransData* data, int len);
		void processDisappear(NDTransData* data, int len);
		void processNpcInfoList(NDTransData* data, int len);
		void processNpcStatus(NDTransData* data, int len);
		void processMonsterInfo(NDTransData* data, int len);
		void processChgPoint(NDTransData* data, int len);
		void processPetInfo(NDTransData* data, int len);
		void processMsgDlg(NDTransData& data);
		//void processLifeSkill(NDTransData& data);
		void processCollection(NDTransData& data);
		//void processLifeSkillSynthesize(NDTransData& data);
		void processNPCInfo(NDTransData& data);
		
		void processRehearse(NDTransData& data);
		void processTeam(NDTransData& data);
		void processGoodFriend(NDTransData& data);
		void processTutor(NDTransData& data);
		
		void processGameQuit(NDTransData* data, int len);
		void processTalk(NDTransData& data);
		
		void processTrade(NDTransData& data);
		
		void processBillBoard(NDTransData& data);
		void processBillBoardField(NDTransData& data);
		void processBillBoardList(NDTransData& data);
		void processBillBoardUser(NDTransData& data);
		
		void processMsgCommonList(NDTransData& data);
		
		void processMsgCommonListRecord(NDTransData& data);
		
		void processShopInfo(NDTransData& data);
		void processShop(NDTransData& data);
		
		void processUserInfoSee(NDTransData& data);
		void processEquipInfo(NDTransData& data);
		
		void processEquipImprove(NDTransData& data);
		void processFormula(NDTransData& data);
		
		void processSkillGoods(NDTransData& data);
		void processMsgSkill(NDTransData& data);
		void processMsgPetSkill(NDTransData& data);
		// 军团相关
		void processSyndicate(NDTransData& data);
		
		void processDigout(NDTransData& data);
		
		void processPlayerLevelUp(NDTransData& data);
		void processNPC(NDTransData& data);
		void processSee(NDTransData& data);
		void processCampStorage(NDTransData& data);
		void processNpcPosition(NDTransData& data);
		void processNpcTalk(NDTransData& data);
		void processItemTypeInfo(NDTransData& data);
		void processWish(NDTransData& data);
		void processCompetition(NDTransData& data);
		void processWalkTo(NDTransData& data);
		
		void processReCharge(NDTransData& data);
		void processRechargeReturn(NDTransData& data);
		
		void processVersionMsg(NDTransData& data);

		void processActivity(NDTransData& data);
		
		void processDeleteRole(NDTransData& data);
		
		void processPortal(NDTransData& data);
		
		void processMarriage(NDTransData& data);
		
		void processRespondTreasureHuntProb(NDTransData& data);
		
		void processShowTreasureHuntAward(NDTransData& data);
		
		void processRespondTreasureHuntInfo(NDTransData& data);
		
		void processKickOutTip(NDTransData& data);
		
		void processQueryPetSkill(NDTransData& data);
		
		void processRoadBlock(NDTransData& data);
		void processBossInfo(NDTransData& data);
		void processBossSelfInfo(NDTransData& data);
		
		void OnMsgNpcList(NDTransData* data);
		void OnMsgMonsterList(NDTransData* data);
		void LoadMapMusic();
		// 地图相关操作
		bool loadSceneByMapDocID(int mapid);
		void LoadSceneMonster();
		CSMBattleScene* loadBattleSceneByMapID(int mapid,int x,int y);
		NDMapLayer* getMapLayerOfScene(NDScene* scene);
		NDMapLayer* getBattleMapLayerOfScene(NDScene* scene);
		NDUILayer* getUILayerOfRunningScene(int iTag);
		int GetMapDocID(){ return m_iMapDocID; }
		int GetMotherMapID();
		int GetMapID(){return m_mapID;}
		// npc相关操作
		void setNpcTaskStateById(int npcId, int state);
		void DelNpc(int iID);
		void ClearNpc();
		void AddAllNpcToMap();
		void AddOneNPC(NDNpc *npc);
		NDNpc* GetNpc(int iID);
		void UpdateNpcLookface(unsigned int idNpc, unsigned int newLookface);
		
		// 怪物相关操作
		void ClearMonster();
		void ClearOneMonster(NDMonster* monster);
		void AddAllMonsterToMap();
		bool GetMonsterInfo(monster_type_info& info, int nType);
		//void ClearOneGP(GatherPoint* gp);
		//void ClearGP();
		NDMonster* GetMonster(int iID);
		void AddOneMonster(NDMonster* monster);
		
		// 战斗相关
		void BattleStart();
		void BattleEnd(int iResult);
		
		// 其它玩家相关操作
		NDManualRole* GetManualRole(int nID);
		NDManualRole* GetManualRole(const char* name);
		void AddManualRole(int nID, NDManualRole* role);
		void DelManualRole(int nID);
		void ClearManualRole();
		map_manualrole& GetManualRoles() { return m_mapManualrole; }
		
		NDManualRole* NearestDacoityManualrole(NDManualRole& role, int iDis);
		
		NDManualRole* NearestBattleFieldManualrole(NDManualRole& role, int iDis);
		
		// 接收服务端下发的物品配置信息
		void OnMsgItemType(NDTransData* data);
		
		// 生活技能相关
		//LifeSkill* getLifeSkill(OBJID idSkill);
		//FormulaMaterialData*  getFormulaData(int idFoumula);
		//void getFormulaBySkill(int idSkill, std::vector<int>& vec_id);
		NDMonster* GetBoss();
		// 返回玩家某个距离范围内与玩家最近的角色或NPC
		NDBaseRole* GetRoleNearstPlayer(int iDistance);
		
		// 返回玩家某个距离范围内下一个目标
		NDBaseRole* GetNextTarget(int iDistance);
		
		int getDistBetweenRole(NDBaseRole *firstrole, NDBaseRole *secondrole);
		
		void ClearNPCChat();
		
		void quitGame();
		
		/**
		 * 大地图中切换地图
		 */
		void WorldMapSwitch(int mapId);
		
		/**
		 * 使用卷轴切换地图
		 */
		void throughMap(int mapX, int mapY, int mapId); 
		
		void NavigateTo(int mapX, int mapY, int mapId); 
		
		void NavigateToNpc(int nNpcId);
		
		//请求列表相关
		//std::vector<RequsetInfo>& GetRequestList() { return m_vecRequest; }
		//bool GetRequest(int iID, RequsetInfo& info);
		//bool DelRequest(int iID);
		//void addRequst(RequsetInfo& request);
		
		// 队伍相关
		void resetTeamPosition(int leadId, int roleId);
		void resetTeamPosition(int teamID);
		NDManualRole* GetTeamRole(int iID);
		void setManualroleTeamID(int iRoleID, int iTeamID);
		bool GetTeamInfo(int iTeamID, s_team_info& info);
		void updateTeamCamp();
		void updateTeamListAddPlayer(NDManualRole& role);
		void updateTeamListDelPlayer(NDManualRole& role);
		std::vector<s_team_info>& GetTeamList(){ return m_vecTeamList; }
		
		std::vector<NDManualRole*> GetPlayerTeamList();		
		
		NDManualRole* GetTeamLeader(int teamID);
		NDManualRole* GetTeamRole(int teamID, int index);
		
		bool DealBugReport();
		bool DealCrashRepotUploadFail();
	public:
		std::string changeNpcString(std::string str);
		int GetCurrentMonsterRound(){return m_nCurrentMonsterRound;}
		// 好友相关
		bool isFriendMax() {
			return true;//this->m_mapFriend.size() >= MAX_FRIEND_NUM;
		}
		
		bool isFriendAdded(string& name);
		
		int GetFriendOnlineNum() const {
			return this->onlineNum;
		}
		
		int GetFriendNum() const {
			return 0;//this->m_mapFriend.size();
		}
		
		bool isMonsterClear();
		
		//MAP_FRIEND_ELEMENT& GetFriendMap() {
		//	return this->m_mapFriend;
		//}
		
		bool canChangeMap() {
			return (this->mapType & MAPTYPE_CHGMAP_DISABLE) == 0;
		}
		
		bool canRecord() {
			return (this->mapType & MAPTYPE_RECORD_DISABLE) == 0;
		}
		
		bool canPk() {
			return (this->mapType & MAPTYPE_PK_DISABLE) == 0;
		}
		
		bool canBooth() {
			return (this->mapType & MAPTYPE_BOOTH_ENABLE) > 0;
		}
		
		bool canBattle() {
			return (this->mapType & MAPTYPE_BATTLE_DISABLE) == 0;
		}
		
		bool canFly() {
			return (this->mapType & MAPTYPE_FLY_DISABLE) == 0 && canDrive();
		}
		
		bool canDrive() {
			return (this->mapType & MAPTYPE_DRIVE_DISABLE) == 0;
		}
		
		bool canTreasureHunt() {
			return (this->mapType & MAPTYPE_NO_TREASURE_HUNT) == 0;
		}
		
		const VEC_NPC& GetNpc() const {
			return this->m_vNpc;
		}
		
		NDNpc* GetNpcByID(int idNpc);
		
		int GetDlgNpcID();
		
		void AddSwitch();
		
	// 邮件相关
	EmailData* GetMail(int iMailID);
	public:
		void SetBattleMonster(NDMonster* monster);
		NDMonster* GetBattleMonster();
	private:
		CAutoLink<NDMonster>	waitbatteleMonster;	
	public:
		VEC_NPC m_vNpc;				// 当前地图显示的所有npc
		VEC_MONSTER m_vMonster;		// 当前地图显示的所有怪
		monster_info m_mapMonsterInfo; // 当前地图所有怪物信息
		map_manualrole m_mapManualrole;// 所有其它玩家
		vec_email m_vEmail;
		//map_gather_point m_mapGP;
		map_npc_store m_mapNpcStore;
		
		/**npc聊天相关*/
		USHORT usData;
		string strLeaveMsg;
		string strTitle;
		string strNPCText;
		string noteTitle; // 公告
		string noteContent;
		struct st_npc_op
		{
			int idx; string str; bool bArrow;
			st_npc_op() { bArrow = false; }
		};
		vector<st_npc_op> vecNPCOPText;
		/**npc聊天相关end*/

		//MAP_LEARNED_LIFE_SKILL m_mapLearnedLifeSkill; // 玩家学会的生活技能
		//
		//map_fomula	m_mapFomula; //配方
		
		int zhengYing[CAMP_TYPE_END];
		
	public:
		static bool bFirstCreate, bVerifyVersion;
		int m_iMapDocID;//地图资源ID
		int m_mapID;//地图实际ID
		CCSize m_sizeMap;
		std::string mapName;
	private:
		int m_nCurrentMonsterRound;
		//std::vector<RequsetInfo> m_vecRequest;
		CIDFactory m_idAlloc;
		
		//　队伍相关
		typedef std::vector<s_team_info>::iterator	vec_team_it;
		std::vector<s_team_info> m_vecTeamList;
		
		// 好友列表
		//MAP_FRIEND_ELEMENT m_mapFriend;
		int onlineNum;
		
		// 技能商店
		typedef map<int/*idNpc*/, VEC_BATTLE_SKILL> MAP_NPC_SKILL_STORE;
		typedef MAP_NPC_SKILL_STORE::iterator MAP_NPC_SKILL_STORE_IT;
		
		MAP_NPC_SKILL_STORE m_mapNpcSkillStore;
		
		int mapType;
		
		int m_iCurDlgNpcID;
	public:
		bool bolEnableAccept; //接受组队
		bool bRootItemZhangKai;
		bool bRootMenuZhangKai;
	private:
		int m_idTradeRole;
		OBJID m_idTradeDlg;
		OBJID m_idAuctionDlg;
		OBJID m_idDeMarry;
		OBJID m_idDialogDemarry;
		OBJID m_idDialogMarry;
		
		int id1, id2; // 结婚的两个id;
	};
	
	void sendPKAction(NDManualRole& role, int pkType);
	void trade(int n, int action);
	void sendAddFriend(std::string& name);
	void sendRehearseAction(int idTarget, int btAction);
	void sendQueryPlayer(int roleId, int btAction);
	void sendTeamAction(int senderID, int action);
	void sendChargeInfo(int iID);
	void sendMarry(int roleId, int playerId, int usType, int usData);
}
