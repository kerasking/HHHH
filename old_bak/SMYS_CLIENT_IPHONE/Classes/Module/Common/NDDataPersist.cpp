/*
 *  NDDataPersist.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDDataPersist.h"
#include "KDirectory.h"
#include "define.h"
#include "ItemMgr.h"

NSString* DataFilePath()
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	return [[documentsDirectory stringByAppendingPathComponent:@"/DragonDrive"] 
								stringByAppendingPathComponent:@"/DragonDrive_" ];
}


/*
 简单的加密算法 
 add by xiezhenghai
 begin.....
 */

static const char codeKey[] = {0x57, 0xf3, 0xa4, 0x38, 0xc0, 0x88, 0x7b, 0xac};
void charToHex(unsigned char src, unsigned char *dest)
{
	int hi = src / 16;      //高位
	int lo = src % 16;      //低位
	
	if (hi >= 0 && hi <= 9) 
		*dest++ = '0' + hi;
	else 
		*dest++ = 'A' + hi - 10;
	
	if (lo >= 0 && lo <= 9) 
		*dest++ = '0' + lo;
	else 
		*dest++ = 'A' + lo - 10;
}

unsigned char hexToChar(const unsigned char *hex)
{
	int hi = 0;
	if (*hex >= '0' && *hex <= '9') 
		hi = (*hex++ - '0') * 16;
	else 
		hi = (*hex++ - 'A' + 10) * 16;
	
	int lo = 0;
	if (*hex >= '0' && *hex <= '9') 
		lo = *hex++ - '0';
	else 
		lo = *hex++ - 'A' + 10;
	return  (hi + lo);
}

void simpleEncode(const unsigned char *src, unsigned char *dest)
{
	int index = 0;
	while (*src) 
	{
		*dest = (*src >> 4) + (*src % 16 << 4);        //高低位对调
		*dest = *dest ^ codeKey[index++];              //高低位对调后得到得值与对应位密钥取异或运算
		charToHex(*dest, dest);                        //异或后得值转化成16进制样式字符串输出
		
		index = index % sizeof(codeKey);               //index的值在密钥范围内重复轮巡		 
		dest = dest + 2;                               //因为16进制样式得值包含两个字符
		src++;
	}
}

void simpleDecode(const unsigned char *src, unsigned char *dest)
{
	int index = 0;
	while (*src) 
	{
		*dest = hexToChar(src);
		*dest = *dest ^ codeKey[index++];
		*dest = (*dest >> 4) + (*dest % 16 << 4);
		
		index = index % sizeof(codeKey);		
		src = src + 2;
		dest++;
	}
}
/*
 简单的加密算法 
 add by xiezhenghai
 end......
 */

const size_t MAX_ACCOUNT = 10;

int NDDataPersist::ms_nGameSetting = 0xFFFFFFFF; // 默认全开

void NDDataPersist::LoadGameSetting()
{
	NDDataPersist gs;
	gs.SaveGameSetting();
}

NDDataPersist::NDDataPersist()
{
	this->LoadData();
	this->LoadAccountList();
	this->LoadAccountDeviceList();
}

NDDataPersist::~NDDataPersist()
{
	[m_pkDataArray release];
	[m_pkAccountList release];
	[m_pkAccountDeviceList release];
}

bool NDDataPersist::NeedEncodeForKey(NSString* key)
{
	if ([key isEqual:kLastServerIP] || [key isEqual:kLastServerPort] || [key isEqual:kLastAccountName] || [key isEqual:kLastAccountPwd])
		return true;
	else 
		return false;
}

void NDDataPersist::SetData(uint index, NSString* key, const char* data)
{
	NSMutableDictionary *dic = this->LoadDataDiction(index);
	NDAsssert(dic != nil);
	if (data) 
	{
		NSString *nsObj = [NSString stringWithUTF8String:data];
		
		if (NeedEncodeForKey(key)) 
		{
			unsigned char encData[1024] = {0x00};
			simpleEncode((const unsigned char*)data, encData);
			nsObj = [NSString stringWithUTF8String:(const char*)encData];
		}
		
		[dic setObject:nsObj forKey:key];
	}
	
}

const char* NDDataPersist::GetData(uint index, NSString* key)
{
	static char decData[1024];
	memset(decData, 0x00, sizeof(decData));
	
	NSMutableDictionary *dic = this->LoadDataDiction(index);
	NDAsssert(dic != nil);
	NSString *nsStr= [dic objectForKey:key];
	if (nsStr == nil) // 键值对不存在, 加入
	{ 
		SetData(index, key, "");
		return decData;
	}
	else 
	{
		if (NeedEncodeForKey(key)) 
		{			
			simpleDecode((const unsigned char*)[nsStr UTF8String], (unsigned char*)decData);
			return decData;
		}
		else 
		{
			return [nsStr UTF8String];
		}
	}	
}

void NDDataPersist::SaveData()
{
	[m_pkDataArray writeToFile:this->GetDataPath() atomically:YES];
}

void NDDataPersist::SaveLoginData()
{
	this->SaveData();
}

NSMutableDictionary* NDDataPersist::LoadDataDiction(uint index)
{
	NDAsssert(m_pkDataArray != nil);
	
	NSMutableDictionary* dic = nil;
	
	if ([m_pkDataArray count] > index) {
		dic = (NSMutableDictionary*)[m_pkDataArray objectAtIndex:index];
	}
	
	if (dic == nil) { // 数据不存在,初始化
		for (uint i = [m_pkDataArray count]; i <= index; i++) {
			dic = [[NSMutableDictionary alloc] init];
			[m_pkDataArray insertObject:dic atIndex:i];
			[dic release];
		}
	}
	
	return dic;
}

void NDDataPersist::LoadData()
{
	NSString *filePath = this->GetDataPath();
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		m_pkDataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		const char* pszGameSetting = this->GetData(kGameSettingData, kGameSetting);
		if (pszGameSetting) { // 已经存储
			NDDataPersist::ms_nGameSetting = atoi(pszGameSetting);
		}
	}
	else
	{
		m_pkDataArray = [[NSMutableArray alloc] init];
	}
}

NSString* NDDataPersist::GetDataPath()
{
	NSString* dir = [kDataFileName stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kDataFileName;
//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
//							     NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *documentsDirectory = [paths objectAtIndex:0]; 
//	return [documentsDirectory stringByAppendingPathComponent:kDataFileName];
}

NSString* NDDataPersist::GetAccountListPath()
{
	NSString* dir = [kFavoriteAccountListFileName stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kFavoriteAccountListFileName;
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
	//							     NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString *documentsDirectory = [paths objectAtIndex:0];
	//	return [documentsDirectory stringByAppendingPathComponent:kFavoriteAccountListFileName];
}

void NDDataPersist::LoadAccountList()
{
	NSString *filePath = this->GetAccountListPath();
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		m_pkAccountList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		m_pkAccountList = [[NSMutableArray alloc] init];
	}	
}

void NDDataPersist::AddAcount(const char* account, const char* pwd)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		NSMutableArray *accountNode = [[NSMutableArray alloc] init];		
		[accountNode addObject:[NSString stringWithUTF8String:(const char*)encAccount]];
		
		if (pwd) 
		{
			unsigned char encPwd[1024] = {0x00};
			simpleEncode((const unsigned char*)pwd, encPwd);
			[accountNode addObject:[NSString stringWithUTF8String:(const char*)encPwd]];
		}
		
		for (NSUInteger i = 0; i < [m_pkAccountList count]; i++) 
		{
			NSArray *tmpAccountNode = [m_pkAccountList objectAtIndex:i];
			NSString *tmpAccount = [tmpAccountNode objectAtIndex:0];
			if ([tmpAccount isEqual:[NSString stringWithUTF8String:(const char*)encAccount]]) 
			{
				[m_pkAccountList removeObject:tmpAccountNode];
				break;
			}
		}
		
		if ([m_pkAccountList count] >= MAX_ACCOUNT) 
		{
			[m_pkAccountList removeObjectAtIndex:0];
		}
		
		[m_pkAccountList addObject:accountNode];
		
		[accountNode release];
	}	
}

void NDDataPersist::GetAccount(VEC_ACCOUNT& vAccount)
{
	vAccount.clear();
	
	NSEnumerator *enumerator;
	enumerator = [m_pkAccountList objectEnumerator];
	
	id account;
	while ((account = [enumerator nextObject]) != nil)
	{
		string acc = [(NSString*)[(NSArray*)account objectAtIndex:0] UTF8String];
		string pwd;
		if ([account count] > 1) 
		{
			pwd = [(NSString*)[(NSArray*)account objectAtIndex:1] UTF8String];
		}
		
		unsigned char decAcc[1024] = {0x00};
		unsigned char decPwd[1024] = {0x00};
		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
		simpleDecode((const unsigned char*)pwd.c_str(), decPwd);
		vAccount.push_back(PAIR_ACCOUNT((const char*)decAcc, (const char*)decPwd));
	}
}

void NDDataPersist::SaveAccountList()
{
	[m_pkAccountList writeToFile:this->GetAccountListPath() atomically:YES];
}

NSString* NDDataPersist::GetAccountDeviceListPath()
{
	NSString* dir = [kFavoriteAccountDeviceListFileName stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kFavoriteAccountDeviceListFileName;
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
	//							     NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString *documentsDirectory = [paths objectAtIndex:0];
	//	return [documentsDirectory stringByAppendingPathComponent:kFavoriteAccountListFileName];
}

void NDDataPersist::LoadAccountDeviceList()
{
	NSString *filePath = this->GetAccountDeviceListPath();
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		m_pkAccountDeviceList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		m_pkAccountDeviceList = [[NSMutableArray alloc] init];
	}	
}

void NDDataPersist::AddAccountDevice(const char* account)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		for (NSUInteger i = 0; i < [m_pkAccountList count]; i++) 
		{
			NSString* tmpAccountNode = (NSString*)[m_pkAccountList objectAtIndex:i];
			if ([tmpAccountNode isEqual:[NSString stringWithUTF8String:(const char*)encAccount]]) 
			{
				return;
			}
		}
		
		[m_pkAccountDeviceList addObject:[NSString stringWithUTF8String:(const char*)encAccount]];
	}	
}

bool NDDataPersist::HasAccountDevice(const char* account)
{
	if (!account) return true;
	
	NSEnumerator *enumerator;
	enumerator = [m_pkAccountDeviceList objectEnumerator];
	
	NSString* tmpAccountNode = [NSString stringWithUTF8String:account];
	
	id object;
	while ((object = [enumerator nextObject]) != nil)
	{
		string acc = [(NSString*)object UTF8String];
		
		unsigned char decAcc[1024] = {0x00};
		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
		
		if ([tmpAccountNode isEqual:[NSString stringWithUTF8String:(const char*)decAcc]]) 
		{
			return true;
		}
	}
	
	return false;
}

void NDDataPersist::SaveAccountDeviceList()
{
	[m_pkAccountDeviceList writeToFile:this->GetAccountDeviceListPath() atomically:YES];
}

void NDDataPersist::SetGameSetting(GAME_SETTING type, bool bOn)
{
	if (bOn) {
		ms_nGameSetting |= type;
	} else {
		ms_nGameSetting &= ~type;
	}
}

bool NDDataPersist::IsGameSettingOn(GAME_SETTING type)
{
	return NDDataPersist::ms_nGameSetting & type;
}

void NDDataPersist::SaveGameSetting()
{
	NSString* strGameSetting = [NSString stringWithFormat:@"%d", ms_nGameSetting];
	this->SetData(kGameSettingData, kGameSetting, [strGameSetting UTF8String]);
	this->SaveData();
}

///////////////////////////////////////
//邮件数据plist

const NSUInteger max_player_save_count = 5;
const NSUInteger max_mail_save_count = 20;

NDEmailDataPersist* NDEmailDataPersist::s_intance = NULL;

NDEmailDataPersist::NDEmailDataPersist()
{
	NDAsssert(s_intance == NULL);
	LoadEmailData();
}

NDEmailDataPersist::~NDEmailDataPersist()
{
	SaveEmailData();
	
	if (emailArray) 
	{
		[emailArray release];
		emailArray = nil;
	}
}

NDEmailDataPersist& NDEmailDataPersist::DefaultInstance()
{
	if (s_intance == NULL) 
	{
		s_intance =  new NDEmailDataPersist;
	}
	
	return *s_intance;
}

void NDEmailDataPersist::Destroy()
{
	if (s_intance != NULL) 
	{
		delete s_intance;
		s_intance = NULL;
	}
}

string NDEmailDataPersist::GetEmailState(int playerid,string mail)
{
	if (mail.empty()) 
	{
		return "";
	}
	
	NSMutableDictionary *dic = this->LoadMailDiction();
	NDAsssert(dic != nil);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
	if (playermail == nil) {
		return "";
	}
	
	NSString *nsStr= [playermail objectForKey:[NSString stringWithUTF8String:mail.c_str()]];
	if (nsStr == nil) {
		return "";
	}
	
	return [nsStr UTF8String];
}

void NDEmailDataPersist::AddEmail(int playerid,string mail, string state)
{
	if (mail.empty()) 
	{
		return;
	}
	
	NSMutableDictionary *dic = this->LoadMailDiction();
	NDAsssert(dic != nil);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
	if (playermail == nil) {
		if ([dic count] > max_player_save_count) {
			NSEnumerator *enumerator;
			enumerator = [dic keyEnumerator];
			id key;
			while ((key = [enumerator nextObject]) != nil) {
				
				[dic removeObjectForKey:key];
				break;
			}
			
		}
		playermail = [[NSMutableDictionary alloc] init];
		[dic setObject:playermail forKey:strPlayer];
		[playermail release];
	}
	
	if ([playermail count] > max_mail_save_count) {
		NSEnumerator *enumerator;
		enumerator = [playermail keyEnumerator];
		id key;
		while ((key = [enumerator nextObject]) != nil) {
			
			[playermail removeObjectForKey:key];
			break;
		}
		
	}
	
	[playermail setObject:[NSString stringWithUTF8String:state.c_str()]
				forKey:[NSString stringWithUTF8String:mail.c_str()]];

}

void NDEmailDataPersist::DelEmail(int playerid,string mail)
{
	if (mail.empty()) 
	{
		return;
	}
	
	NSMutableDictionary *dic = this->LoadMailDiction();
	NDAsssert(dic != nil);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
	if (playermail == nil) {
		return;
	}
	
	[playermail removeObjectForKey:[NSString stringWithUTF8String:mail.c_str()]];
}

void NDEmailDataPersist::LoadEmailData()
{
	NSString* filePath = GetEmailPath();
	if (!filePath) 
	{
		emailArray = [[NSMutableArray alloc] init];
		return;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		emailArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		emailArray = [[NSMutableArray alloc] init];
	}
	
}

void NDEmailDataPersist::SaveEmailData()
{
	NSString* filePath = GetEmailPath();
	if (filePath) 
	{
		[emailArray writeToFile:filePath atomically:YES];
	}
	
	[emailArray release];
	emailArray = nil;
}

NSString* NDEmailDataPersist::GetEmailPath()
{
	NSString* dir = [kEmailFileName stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kEmailFileName;
//	if (!file) 
//	{
//		return nil;
//	}
//	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
//														 NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *documentsDirectory = [paths objectAtIndex:0]; 
//	return [documentsDirectory stringByAppendingPathComponent:file];
}

NSMutableDictionary* NDEmailDataPersist::LoadMailDiction()
{
	NDAsssert(emailArray != nil);
	
	NSMutableDictionary* dic = nil;
	
	if ([emailArray count] > 0) {
		NDAsssert([emailArray count] == 1);
		dic = (NSMutableDictionary*)[emailArray objectAtIndex:0];
	}
	
	if (dic == nil) { // 数据不存在,初始化
			dic = [[NSMutableDictionary alloc] init];
			[emailArray addObject:dic];
			[dic release];
	}
	
	return dic;
}

//quick talk data

NDQuickTalkDataPersist::NDQuickTalkDataPersist()
{
	this->LoadQuickTalkData();
}

NDQuickTalkDataPersist::~NDQuickTalkDataPersist()
{
	this->SaveQuickTalkData();
	[quickTalkArray release];
}

NDQuickTalkDataPersist& NDQuickTalkDataPersist::DefaultInstance()
{
	static NDQuickTalkDataPersist obj;
	return obj;
}

void NDQuickTalkDataPersist::GetAllQuickTalkString(int idPlayer, vector<string>& vMsg)
{
	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
	
	// 没有该玩家的快捷聊天记录，新建
	if (arrMsg == nil) {
		if ([dic count] >= QT_MAX_PLAYER_SAVE_NUM) {
			NSEnumerator *enumerator;
			enumerator = [dic keyEnumerator];
			id key;
			while ((key = [enumerator nextObject]) != nil) {
				[dic removeObjectForKey:key];
				break;
			}
		}
		
		arrMsg = [[NSMutableArray alloc] initWithObjects:
				  kSysQuickTalk1, kSysQuickTalk2, kSysQuickTalk3, kSysQuickTalk4, kSysQuickTalk5, 
				  @"", @"", @"", @"", @"", 
				  nil];
		
		[dic setObject:arrMsg forKey:strPlayer];
		[arrMsg release];
		
		this->SaveQuickTalkData();
	}
	
	for (NSUInteger i = 0; i < [arrMsg count]; i++) {
		NSString* msg = (NSString*)[arrMsg objectAtIndex:i];
		vMsg.push_back(string([msg UTF8String]));
	}
}

string NDQuickTalkDataPersist::GetQuickTalkString(int idPlayer, uint uIdx)
{
	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
	
	string str;
	
	if (uIdx < [arrMsg count]) {
		str = [(NSString*)[arrMsg objectAtIndex:uIdx] UTF8String];
	}
	
	return str;
}

void NDQuickTalkDataPersist::SetQuickTalkString(int idPlayer, uint uIdx, const string& msg)
{
	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
	if (uIdx < [arrMsg count]) {
		[arrMsg replaceObjectAtIndex:uIdx withObject:[NSString stringWithUTF8String:msg.c_str()]];
		this->SaveQuickTalkData();
	}
}

void NDQuickTalkDataPersist::LoadQuickTalkData()
{
	NSString* filePath = this->GetQuickTalkPath();
	if (!filePath) 
	{
		quickTalkArray = [[NSMutableArray alloc] init];
		return;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		quickTalkArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		quickTalkArray = [[NSMutableArray alloc] init];
	}
}

void NDQuickTalkDataPersist::SaveQuickTalkData()
{
	NSString* filePath = this->GetQuickTalkPath();
	if (filePath) 
	{
		[quickTalkArray writeToFile:filePath atomically:YES];
	}
}

NSString* NDQuickTalkDataPersist::GetQuickTalkPath()
{
	NSString* dir = [kQuickTalkFileName stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kQuickTalkFileName;
}

NSMutableDictionary* NDQuickTalkDataPersist::LoadQuickTalkDiction()
{
	NSMutableDictionary* dic = nil;
	
	if ([quickTalkArray count] > 0) {
		NDAsssert([quickTalkArray count] == 1);
		dic = (NSMutableDictionary*)[quickTalkArray objectAtIndex:0];
	}
	
	if (dic == nil) { // 数据不存在,初始化
		dic = [[NSMutableDictionary alloc] init];
		[quickTalkArray addObject:dic];
		[dic release];
	}
	
	return dic;
}

// 物品栏配置
// 循环位移，用于物品id加密
unsigned int _rotl(unsigned int value, int shift) {
	if ((shift &= 31) == 0) {
		return value;
	}
	return (value << shift) | (value >> (32 - shift));
}

unsigned int _rotr(unsigned int value, int shift) {
	if ((shift &= 31) == 0) {
		return value;
	}
	return (value >> shift) | (value << (32 - shift));
}

NDItemBarDataPersist::NDItemBarDataPersist()
{
	this->LoadData();
}

NDItemBarDataPersist::~NDItemBarDataPersist()
{
	this->SaveData();
	[itemBarArray release];
}

NDItemBarDataPersist& NDItemBarDataPersist::DefaultInstance()
{
	static NDItemBarDataPersist obj;
	return obj;
}

void NDItemBarDataPersist::GetItemBarConfigInBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
{
	NSMutableDictionary* dic = this->LoadDictionInBattle();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arr = [dic objectForKey:strPlayer];
	
	// 没有该玩家的物品栏记录，新建
	if (arr == nil) {
		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
			NSEnumerator *enumerator;
			enumerator = [dic keyEnumerator];
			id key;
			while ((key = [enumerator nextObject]) != nil) {
				[dic removeObjectForKey:key];
				break;
			}
		}
		
		arr = [[NSMutableArray alloc] init];
		
		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM; i++) {
			[arr addObject:[NSNumber numberWithInt:0]];
		}
		
		[dic setObject:arr forKey:strPlayer];
		[arr release];
		
		this->SaveData();
	}
	
	for (NSUInteger i = 0; i < [arr count]; i++) {
		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
		int idItemType = _rotl([num unsignedIntValue], kIDShift);
		if (idItemType >= 0) {
			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
		}
	}
}

void NDItemBarDataPersist::GetItemBarConfigOutBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
{
	NSMutableDictionary* dic = this->LoadDictionOutBattle();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arr = [dic objectForKey:strPlayer];
	
	// 没有该玩家的物品栏记录，新建
	if (arr == nil) {
		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
			NSEnumerator *enumerator;
			enumerator = [dic keyEnumerator];
			id key;
			while ((key = [enumerator nextObject]) != nil) {
				[dic removeObjectForKey:key];
				break;
			}
		}
		
		arr = [[NSMutableArray alloc] init];
		
		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
			[arr addObject:[NSNumber numberWithInt:0]];
		}
		
		[dic setObject:arr forKey:strPlayer];
		[arr release];
		
		this->SaveData();
	}
	
	if ([arr count] < IB_MAX_ITEM_NUM_OUT_BATTLE)
	{
		NSUInteger i = [arr count];
		for (; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
			[arr addObject:[NSNumber numberWithInt:0]];
		}
		
		this->SaveData();
	}
	
	for (NSUInteger i = 0; i < [arr count]; i++) {
		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
		int idItemType = _rotl([num unsignedIntValue], kIDShift);
		if (idItemType >= 0) {
			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
		}
	}
}

void NDItemBarDataPersist::SetItemAtIndexInBattle(int idPlayer, uint uIdx, int idItemtype)
{
	NSMutableDictionary* dic = this->LoadDictionInBattle();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arr = [dic objectForKey:strPlayer];
	
	if (uIdx < [arr count]) {
		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
		this->SaveData();
	}
}

void NDItemBarDataPersist::SetItemAtIndexOutBattle(int idPlayer, uint uIdx, int idItemtype)
{
	NSMutableDictionary* dic = this->LoadDictionOutBattle();
	NDAsssert(nil != dic);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
	NSMutableArray *arr = [dic objectForKey:strPlayer];
	
	if (uIdx < [arr count]) {
		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
		this->SaveData();
	}
}

void NDItemBarDataPersist::LoadData()
{
	NSString* filePath = this->GetPath();
	if (!filePath) 
	{
		itemBarArray = [[NSMutableArray alloc] init];
		return;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		itemBarArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		itemBarArray = [[NSMutableArray alloc] init];
	}
}

void NDItemBarDataPersist::SaveData()
{
	NSString* filePath = this->GetPath();
	if (filePath) 
	{
		[itemBarArray writeToFile:filePath atomically:YES];
	}
}

NSString* NDItemBarDataPersist::GetPath()
{
	NSString* dir = [kItemBarFileName stringByDeletingLastPathComponent];
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	return kItemBarFileName;
}

NSMutableDictionary* NDItemBarDataPersist::LoadDictionOutBattle()
{
	NSMutableDictionary* dic = nil;
	
	if ([itemBarArray count] > 0) {
		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:0];
	}
	
	if (dic == nil) { // 数据不存在,初始化
		dic = [[NSMutableDictionary alloc] init];
		[itemBarArray addObject:dic];
		[dic release];
	}
	
	return dic;
}

NSMutableDictionary* NDItemBarDataPersist::LoadDictionInBattle()
{
	this->LoadDictionOutBattle();
	
	NSMutableDictionary* dic = nil;
	
	if ([itemBarArray count] > 1) {
		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:1];
	}
	
	if (dic == nil) { // 数据不存在,初始化
		NDAsssert([itemBarArray count] == 1);
		dic = [[NSMutableDictionary alloc] init];
		[itemBarArray addObject:dic];
		[dic release];
	}
	
	return dic;
}


#pragma mark plist 基本操作
//通过LoadMailDiction调用获取数据字典,数据字典可加入object-c数据对象,数据保存与加载在构造与析构中自动完成

NDDataPlistBasic::NDDataPlistBasic(string filename)
{
	dataArray = nil;
	
	m_filename = filename;
	
	LoadData();
}

NDDataPlistBasic::~NDDataPlistBasic()
{
	SaveData();
	
	[dataArray release];
	dataArray = nil;
}

NSString* NDDataPlistBasic::GetPath(string filename)
{
	NSString* name = [NSString stringWithFormat:@"%@%s.plist", DataFilePath(), filename.c_str()];
	NSString* dir = [name stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	{
		if (!KDirectory::createDir([dir UTF8String]))
		{
			return nil;
		}
	}
	
	return name;
}

void NDDataPlistBasic::LoadData()
{
	NSString* filePath = GetPath(m_filename);
	if (!filePath) 
	{
		dataArray = [[NSMutableArray alloc] init];
		return;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{ 
		dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	}
	else
	{
		dataArray = [[NSMutableArray alloc] init];
	}
}

void NDDataPlistBasic::SaveData()
{
	NSString* filePath = GetPath(m_filename);
	if (filePath && dataArray) 
	{
		[dataArray writeToFile:filePath atomically:YES];
	}
}

NSMutableDictionary* NDDataPlistBasic::LoadMailDiction()
{
	NDAsssert(dataArray != nil);
	
	NSMutableDictionary* dic = nil;
	
	if ([dataArray count] > 0) {
		NDAsssert([dataArray count] == 1);
		dic = (NSMutableDictionary*)[dataArray objectAtIndex:0];
	}
	
	if (dic == nil) { // 数据不存在,初始化
		dic = [[NSMutableDictionary alloc] init];
		[dataArray addObject:dic];
		[dic release];
	}
	
	return dic;
}


#pragma mark 玩家提交bug
// NDQuestionDataPlist负责保存玩家提问数据(玩家每天最多提10个问题)
#define MAX_QUEST_BUG_COUNT_PER_DAY (10)
#define PER_DAY_SECOND (3600 * 24)

NDQuestionDataPlist::NDQuestionDataPlist() : 
NDDataPlistBasic("questbug")
{
}

NDQuestionDataPlist::~NDQuestionDataPlist()
{
}

bool NDQuestionDataPlist::CanPlayerQuestCurrentDay(int playerId)
{
	return !IsOverCount(GetPlayerCurQuestCount(playerId));
}

void NDQuestionDataPlist::AddPlayerQuest(int playerId)
{
	IncPlayerQuestCount(playerId);
}

int NDQuestionDataPlist::GetPlayerCurTime(int playerId)
{
	NSMutableArray* quest = GetQuestData(playerId);
	
	if (quest == nil) return 0;
	
	NSNumber *num = [quest objectAtIndex:0];
	
	if (!num) return 0;
	
	return [num floatValue];
}

bool NDQuestionDataPlist::IsOverTime(double time)
{
	double cur = [NSDate timeIntervalSinceReferenceDate];
	if ( int(cur - time) > PER_DAY_SECOND)
		return true;
		
	return false;
}

int NDQuestionDataPlist::GetPlayerCurQuestCount(int playerId)
{
	NSMutableArray* quest = GetQuestData(playerId);
	
	if (quest == nil) return 0;
	
	NSNumber *num = [quest objectAtIndex:1];
	
	if (!num) return 0;
	
	return [num intValue];
}

bool NDQuestionDataPlist::IsOverCount(int count)
{
	if (count >= MAX_QUEST_BUG_COUNT_PER_DAY)
		return true;
		
	return false;
}

NSMutableArray* NDQuestionDataPlist::GetQuestData(int playerId)
{
	NSMutableDictionary *dic = this->LoadMailDiction();
	NDAsssert(dic != nil);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
	
	if (playerQuest == nil) {
		NSMutableArray *quest = [[NSMutableArray alloc] init];
		[quest addObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]]];
		[quest addObject:[NSNumber numberWithInt:0]];
		
		[dic setObject:quest forKey:strPlayer];
		
		[quest release];
	}
	
	playerQuest = [dic objectForKey:strPlayer];
	
	NSNumber *num = [playerQuest objectAtIndex:0];
	
	if (IsOverTime([num doubleValue]))
	{
		ResetPlayerQuest(playerId);
	}
	
	return [dic objectForKey:strPlayer];
}

void NDQuestionDataPlist::ResetPlayerQuest(int playerId)
{
	NSMutableDictionary *dic = this->LoadMailDiction();
	NDAsssert(dic != nil);
	
	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
	
	if (playerQuest != nil) {
		[dic removeObjectForKey:strPlayer];
		
		GetQuestData(playerId);
	}
}

void NDQuestionDataPlist::IncPlayerQuestCount(int playerId)
{
	NSMutableArray* quest = GetQuestData(playerId);
	
	if (quest == nil) return;
	
	NSNumber *num = [quest objectAtIndex:1];
	
	if (num == nil)
		return;
	
	[quest replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[num intValue]+1]];
	
	this->SaveData();
}

