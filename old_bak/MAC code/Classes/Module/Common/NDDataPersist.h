/*
 *  NDDataPersist.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_DATA_PERSIST_H__
#define __ND_DATA_PERSIST_H__

#include <string>
#include <vector>
#include "Singleton.h"

#ifdef DataFilePath
#undef DataFilePath
#endif

NSString* DataFilePath();

#define kDataFileName [NSString stringWithFormat:@"%@/data.plist", DataFilePath()]

// 上次登录信息
#define kLoginData 0
#define kLastServerName @"LastServerName"
#define kLastServerIP @"LastServerIP"
#define kLastServerPort @"LastServerPort"
#define kLastAccountName @"LastAccountName"
#define kLastAccountPwd @"LastAccountPwd"
#define kLastServerSendName @"LastServerSendName"
#define kLinkType @"LinkType"

// 游戏设置
#define kGameSettingData 1
#define kGameSetting @"GameSetting"

#ifdef CPLOG

// cpLog配置信息
#define kCpLogData 2
#define kCpLogServerIP @"CpLogServerIP"
#define kCpLogServerPort @"CpLogServerPort"

#endif

#define kFavoriteAccountListFileName [NSString stringWithFormat:@"%@/accountList.plist", DataFilePath()]
#define kFavoriteAccountDeviceListFileName [NSString stringWithFormat:@"%@/accountDeviceList.plist", DataFilePath()]

using std::string;
using std::pair;
using std::vector;

typedef pair<string, string> PAIR_ACCOUNT;
typedef vector<PAIR_ACCOUNT> VEC_ACCOUNT;
typedef VEC_ACCOUNT::iterator VEC_ACCOUNT_IT;
typedef VEC_ACCOUNT::reverse_iterator VEC_ACCOUNT_REVERSE_IT;

enum GAME_SETTING {
	GS_SHOW_HEAD = 0x01,
	GS_SHOW_MINI_MAP = 0x02,
	GS_SHOW_WORLD_CHAT = 0x04,
	GS_SHOW_SYN_CHAT = 0x08,
	GS_SHOW_TEAM_CHAT = 0x10,
	GS_SHOW_AREA_CHAT = 0x20,
	GS_SHOW_NAME = 0x40,
	GS_SHOW_OTHER_PLAYER = 0x80,
	GS_SHOW_DIRECT_KEY = 0x100,
};

void simpleDecode(const unsigned char *src, unsigned char *dest);
void simpleEncode(const unsigned char *src, unsigned char *dest);

class NDDataPersist
{
public:
	static void LoadGameSetting();
	static bool IsGameSettingOn(GAME_SETTING type);
	
public:
	NDDataPersist();
	~NDDataPersist();
	
	void SaveData();
	
	void SetGameSetting(GAME_SETTING type, bool bOn);
	void SaveGameSetting();
	void SaveLoginData();
	
	void SetData(uint index, NSString* key, const char* data);
	const char* GetData(uint index, NSString* type);
	
	void AddAcount(const char* account, const char* pwd);
	void GetAccount(VEC_ACCOUNT& vAccount);
	void SaveAccountList();
	
	void AddAccountDevice(const char* account);
	bool HasAccountDevice(const char* account);
	void SaveAccountDeviceList();
	
private:
	// 上次登录帐号，密码及服务器地址, 游戏设置
	NSMutableArray *dataArray;
	// 常用帐号列表
	NSMutableArray *accountList;
	
	NSMutableArray *accountDeviceList;
	
	static int s_gameSetting;
	
private:
	void LoadData();
	NSString* GetDataPath();
	
	// 获取配置信息
	NSMutableDictionary* LoadDataDiction(uint index);
	
	void LoadAccountList();
	NSString* GetAccountListPath();
	
	void LoadAccountDeviceList();
	NSString* GetAccountDeviceListPath();
	
	bool NeedEncodeForKey(NSString* key);
};

///////////////////////////////////////
//邮件数据plist
#define kEmailFileName [NSString stringWithFormat:@"%@/email.plist", DataFilePath()]

class NDEmailDataPersist
{
public: 
	~NDEmailDataPersist();
	static NDEmailDataPersist& DefaultInstance();
	static void Destroy();
	
	string GetEmailState(int playerid, string mail);
	void AddEmail(int playerid, string mail, string state); 
	void DelEmail(int playerid, string mail);
	
private:
	NDEmailDataPersist();
	void LoadEmailData();
	void SaveEmailData();
	NSString* GetEmailPath();
	NSMutableDictionary* LoadMailDiction();
	
private:
	NSMutableArray *emailArray;
	
	static NDEmailDataPersist* s_intance;
};

//战斗内快捷聊天
#define kQuickTalkFileName [NSString stringWithFormat:@"%@/quickTalk.plist", DataFilePath()]
#define QT_MAX_PLAYER_SAVE_NUM 5
#define QT_MAX_MESSAGE_NUM 10

// 系统默认5个快捷聊天
#define kSysQuickTalk1 NDCommonCString_RETNS("QuickChatBeQuick")
#define kSysQuickTalk2 NDCommonCString_RETNS("QuickChatGood")
#define kSysQuickTalk3 NDCommonCString_RETNS("QuickChatFlee")
#define kSysQuickTalk4 NDCommonCString_RETNS("QuickChatJiaYou")
#define kSysQuickTalk5 NDCommonCString_RETNS("QuickChatYun")

class NDQuickTalkDataPersist {
public:
	~NDQuickTalkDataPersist();
	static NDQuickTalkDataPersist& DefaultInstance();
	
	void GetAllQuickTalkString(int idPlayer, vector<string>& vMsg);
	string GetQuickTalkString(int idPlayer, uint uIdx);
	void SetQuickTalkString(int idPlayer, uint uIdx, const string& msg);
	
private:
	NDQuickTalkDataPersist();
	void LoadQuickTalkData();
	void SaveQuickTalkData();
	NSString* GetQuickTalkPath();
	NSMutableDictionary* LoadQuickTalkDiction();
	
private:
	NSMutableArray* quickTalkArray;
};

// 物品栏配置，战斗内和战斗外分别保存
#define kItemBarFileName [NSString stringWithFormat:@"%@/itemBar.plist", DataFilePath()]
#define IB_MAX_PLAYER_SAVE_NUM 5
#define IB_MAX_ITEM_NUM 17
#define IB_MAX_ITEM_NUM_OUT_BATTLE 18
#define kIDShift 3

struct ItemBarCellInfo {
	ItemBarCellInfo(int idType, int pos)
	{
		idItemType = idType;
		nPos = pos;
	}
	int idItemType;
	int nPos;
};

typedef vector<ItemBarCellInfo> VEC_ITEM_BAR_CELL;

class NDItemBarDataPersist {
public:
	~NDItemBarDataPersist();
	static NDItemBarDataPersist& DefaultInstance();
	
	void GetItemBarConfigInBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo);
	void SetItemAtIndexInBattle(int idPlayer, uint uIdx, int idItemtype);
	
	void GetItemBarConfigOutBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo);
	void SetItemAtIndexOutBattle(int idPlayer, uint uIdx, int idItemtype);
	
private:
	NDItemBarDataPersist();
	void LoadData();
	void SaveData();
	NSString* GetPath();
	NSMutableDictionary* LoadDictionInBattle();
	NSMutableDictionary* LoadDictionOutBattle();
	
private:
	NSMutableArray* itemBarArray;
};

#pragma mark plist 基本操作
//通过LoadMailDiction调用获取数据字典,数据字典可加入object-c数据对象,数据保存与加载在构造与析构中自动完成
class NDDataPlistBasic
{
public:
	NDDataPlistBasic(string filename);
	virtual ~NDDataPlistBasic() = 0;
	
protected:
	NSString* GetPath(string filename);
	void LoadData();
	void SaveData();
protected:
	NSMutableArray *dataArray;
	NSMutableDictionary* LoadMailDiction();
	
	string m_filename;
};

#pragma mark 玩家提交bug
// NDQuestionDataPlist负责保存玩家提问数据(玩家每天最多提10个问题)
class NDQuestionDataPlist : public NDDataPlistBasic
{
public:
	NDQuestionDataPlist();
	~NDQuestionDataPlist();
	
	bool CanPlayerQuestCurrentDay(int playerId);
	void AddPlayerQuest(int playerId);
	
private:
	int GetPlayerCurTime(int playerId);
	bool IsOverTime(double time);
	int GetPlayerCurQuestCount(int playerId);
	bool IsOverCount(int count);
	
	NSMutableArray *GetQuestData(int playerId);
	void ResetPlayerQuest(int playerId);
	void IncPlayerQuestCount(int playerId);
};

#endif