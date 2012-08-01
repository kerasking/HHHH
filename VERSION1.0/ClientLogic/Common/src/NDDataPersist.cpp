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
#include <direct.h>

NSString* DataFilePath()
{
	/***
	* 临时性注释 郭浩
	* begin
	*/
// 	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
// 	NSString *documentsDirectory = [paths objectAtIndex:0]; 
// 	return [[documentsDirectory stringByAppendingPathComponent:@"/DragonDrive"] 
// 								stringByAppendingPathComponent:@"/DragonDrive_" ];
	/***
	* 临时性注释
	* end
	*/

	char szTempPath[MAX_PATH] = {0};

	getcwd(szTempPath,MAX_PATH);

	return new CCString("szTempPath");
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

int NDDataPersist::s_gameSetting = 0xFFFFFFFF; // 默认全开

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
	dataArray->release();
	accountList->release();
	accountDeviceList->release();
// 	[dataArray release];
// 	[accountList release];
// 	[accountDeviceList release];
}

bool NDDataPersist::NeedEncodeForKey(NSString* key)
{
	if (key->isEqual(&kLastServerIP) ||
		key->isEqual(&kLastServerPort) ||
		key->isEqual(&kLastAccountName) ||
		key->isEqual(&kLastAccountPwd))
	{
		return true;
	}
	else
	{
		return false;
	}
}

void NDDataPersist::SetData(unsigned int index, NSString* key, const char* data)
{
	CCMutableDictionary<const char*>* dic = LoadDataDiction(index);
	NDAsssert(dic != nil);
	if (data) 
	{
//		NSString *nsObj = [NSString stringWithUTF8String:data];
		NSString* nsObj = NSString::stringWithUTF8String(data);
		
		if (NeedEncodeForKey(key)) 
		{
			unsigned char encData[1024] = {0x00};
			simpleEncode((const unsigned char*)data, encData);
			nsObj = NSString::stringWithUTF8String((const char*)encData);
			//nsObj = [NSString stringWithUTF8String:(const char*)encData];
		}
		
		//[dic setObject:nsObj forKey:key];
		dic->setObject(nsObj,key->toStdString().c_str());
	}
	
}

const char* NDDataPersist::GetData(unsigned int index, NSString* key)
{
	static char decData[1024] = {0};
	memset(decData, 0x00, sizeof(decData));
	
	CCMutableDictionary<const char*>* dic = LoadDataDiction(index);
	NDAsssert(dic != nil);
	NSString* nsStr = (NSString*)dic->objectForKey(key->toStdString().c_str());

	if (nsStr == nil) // 键值对不存在, 加入
	{ 
		SetData(index, key, "");
		return decData;
	}
	else
	{
		if (NeedEncodeForKey(key)) 
		{			
			//simpleDecode((const unsigned char*)[nsStr UTF8String], (unsigned char*)decData);
			simpleDecode((const unsigned char*)nsStr->UTF8String(),(unsigned char*)decData);
			return decData;
		}
		else 
		{
			return nsStr->toStdString().c_str();
		}
	}	
}

void NDDataPersist::SaveData()
{
//	[dataArray writeToFile:this->GetDataPath() atomically:YES];
	//dataArray->writeToFile(GetDataPath(),YES);
}

void NDDataPersist::SaveLoginData()
{
	this->SaveData();
}

CCMutableDictionary<const char*>* NDDataPersist::LoadDataDiction(unsigned int index)
{
	NDAsssert(dataArray != nil);
	
	CCMutableDictionary<const char*>* dic = nil;
	
	if (dataArray->count() > index)
	{
		dic = (CCMutableDictionary<const char*>*)dataArray->getObjectAtIndex(index);
	}
	
	if (dic == nil)
	{ // 数据不存在,初始化
		for (unsigned int i = dataArray->count(); i <= index; i++) 
		{
			dic = new CCMutableDictionary<const char*>;
			dataArray->insertObjectAtIndex(dic,i);
			SAFE_DELETE(dic);
// 			[dataArray insertObject:dic atIndex:i];
// 			[dic release];
		}
	}
	
	return dic;
}

void NDDataPersist::LoadData()
{
 	NSString *filePath = this->GetDataPath();
// 	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
// 	{ 
// 		dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
// 		const char* pszGameSetting = this->GetData(kGameSettingData, kGameSetting);
// 
// 		if (pszGameSetting) 
// 		{ // 已经存储
// 			NDDataPersist::s_gameSetting = atoi(pszGameSetting);
// 		}
// 	}
// 	else
// 	{
// 		dataArray = [[NSMutableArray alloc] init];
// 	}

	dataArray = new CCMutableArray<CCObject*>;
}

NSString* NDDataPersist::GetDataPath()
{
//	NSString* dir = [kDataFileName stringByDeletingLastPathComponent];

	// 	NSString* dir = new NSString("");
	// 
	// 	if (!KDirectory::isDirectoryExist(dir->toStdString().c_str())) 
	// 	{
	// 		if (!KDirectory::createDir(dir->toStdString().c_str()))
	// 		{
	// 			return nil;
	// 		}
	// 	}


	return pkDataFileName;
//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
//							     NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *documentsDirectory = [paths objectAtIndex:0]; 
//	return [documentsDirectory stringByAppendingPathComponent:kDataFileName];
}

NSString* NDDataPersist::GetAccountListPath()
{
// 	NSString* dir = [kFavoriteAccountListFileName stringByDeletingLastPathComponent] ;
// 	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
// 	{
// 		if (!KDirectory::createDir([dir UTF8String]))
// 		{
// 			return nil;
// 		}
// 	}
// 	return kFavoriteAccountListFileName;
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
	//							     NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString *documentsDirectory = [paths objectAtIndex:0];
	//	return [documentsDirectory stringByAppendingPathComponent:kFavoriteAccountListFileName];

	return new NSString("");
}

void NDDataPersist::LoadAccountList()
{
	/***
	* 临时性注释 郭浩
	* all
	*/
// 	NSString *filePath = this->GetAccountListPath();
// 	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
// 	{ 
// 		accountList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
// 	}
// 	else
// 	{
// 		accountList = [[NSMutableArray alloc] init];
// 	}	
}

void NDDataPersist::AddAcount(const char* account, const char* pwd)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		CCMutableArray<CCObject*>* accountNode = new CCMutableArray<CCObject*>;

		accountNode->addObject(&NSString((const char*)encAccount));
		//[accountNode addObject:[NSString stringWithUTF8String:(const char*)encAccount]];
		
		if (pwd)
		{
			unsigned char encPwd[1024] = {0x00};
			simpleEncode((const unsigned char*)pwd, encPwd);
			//[accountNode addObject:[NSString stringWithUTF8String:(const char*)encPwd]];

			accountNode->addObject(&NSString((const char*)encPwd));
		}
		
		for (int i = 0; i < accountList->count(); i++) 
		{
			CCArray* tmpAccountNode = (CCArray*)accountList->objectAtIndex(i);
			NSString *tmpAccount = (NSString*)tmpAccountNode->objectAtIndex(0);

			if (tmpAccount->isEqual(new NSString((const char*) encAccount)))
			{
				accountList->removeObject(tmpAccount);
			}

// 			if ([tmpAccount isEqual:[NSString stringWithUTF8String:(const char*)encAccount]]) 
// 			{
// 				[accountList removeObject:tmpAccountNode];
// 				break;
// 			}
		}
		
		if (accountList->count() >= MAX_ACCOUNT) 
		{
			//[accountList removeObjectAtIndex:0];
			accountList->removeObjectAtIndex(0);
		}
		
		accountList->addObject(accountNode);
		//[accountList addObject:accountNode];
		
		accountNode->release();
	}	
}

void NDDataPersist::GetAccount(VEC_ACCOUNT& vAccount)
{
	vAccount.clear();
	
// 	NSEnumerator *enumerator;
// 	enumerator = [accountList objectEnumerator];
	
	CCArray* account = 0;

	for (int i = 0;i < accountList->count();i++)
	{
		account = (CCArray*)accountList->objectAtIndex(i);
		string acc = ((NSString*)(account->objectAtIndex(0)))->toStdString();
		string pwd = "";

		if (account->count() > 1)
		{
			pwd = ((NSString*)(account->objectAtIndex(1)))->toStdString();
		}

		unsigned char decAcc[1024] = {0x00};
		unsigned char decPwd[1024] = {0x00};

		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
		simpleDecode((const unsigned char*)pwd.c_str(), decPwd);

		vAccount.push_back(PAIR_ACCOUNT((const char*)decAcc, (const char*)decPwd));
	}

	/***
	* objective-c的旧代码
	* 已被替换 郭浩
	*/
// 	while ((account = accountList->) != nil)
// 	{
// 		string acc = [(NSString*)[(NSArray*)account objectAtIndex:0] UTF8String];
// 		string pwd;
// 		if ([account count] > 1) 
// 		{
// 			pwd = [(NSString*)[(NSArray*)account objectAtIndex:1] UTF8String];
// 		}
// 		
// 		unsigned char decAcc[1024] = {0x00};
// 		unsigned char decPwd[1024] = {0x00};
// 		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
// 		simpleDecode((const unsigned char*)pwd.c_str(), decPwd);
// 		vAccount.push_back(PAIR_ACCOUNT((const char*)decAcc, (const char*)decPwd));
// 	}
}

void NDDataPersist::SaveAccountList()
{
//	[accountList writeToFile:this->GetAccountListPath() atomically:YES];
	accountList->writeToFile(GetAccountListPath(),YES);
}

NSString* NDDataPersist::GetAccountDeviceListPath()
{
/***
* 临时性注释 郭浩
* begin
*/

	// 	NSString* dir = [kFavoriteAccountDeviceListFileName stringByDeletingLastPathComponent];
	// 
	// 	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
	// 	{
	// 		if (!KDirectory::createDir([dir UTF8String]))
	// 		{
	// 			return nil;
	// 		}
	// 	}
	// 	return kFavoriteAccountDeviceListFileName;

/***
* 临时性注释 郭浩
* end
*/
	return 0;

	//	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
	//							     NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString *documentsDirectory = [paths objectAtIndex:0];
	//	return [documentsDirectory stringByAppendingPathComponent:kFavoriteAccountListFileName];
}

void NDDataPersist::LoadAccountDeviceList()
{
	NSString* filePath = GetAccountDeviceListPath();

	/***
	* 以下为旧代码 郭浩
	*/
// 	NSString *filePath = this->GetAccountDeviceListPath();
// 	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
// 	{ 
// 		accountDeviceList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
// 	}
// 	else
// 	{
// 		accountDeviceList = [[NSMutableArray alloc] init];
// 	}	
}

void NDDataPersist::AddAccountDevice(const char* account)
{	
	if (account) 
	{
		unsigned char encAccount[1024] = {0x00};
		simpleEncode((const unsigned char*)account, encAccount);
		
		for (NSUInteger i = 0; i < accountList->count(); i++) 
		{
			NSString* tmpAccountNode = (NSString*)accountList->objectAtIndex(i);

			if (tmpAccountNode->isEqual(NSString::stringWithUTF8String((const char*)encAccount)))
			{
				return;
			}

// 			if ([tmpAccountNode isEqual:[NSString stringWithUTF8String:(const char*)encAccount]]) 
// 			{
// 				return;
// 			}
		}
		
		//[accountDeviceList addObject:[NSString stringWithUTF8String:(const char*)encAccount]];
		accountDeviceList->addObject(NSString::stringWithUTF8String((const char*)encAccount));
	}	
}

bool NDDataPersist::HasAccountDevice(const char* account)
{
	/***
	* 旧代码 郭浩
	*/

	if (!account)
	{
		return true;
	}
	
	NSString* tmpAccountNode = NSString::stringWithUTF8String(account);

// 	NSEnumerator *enumerator;
// 	enumerator = [accountDeviceList objectEnumerator];
// 	
// 	NSString* tmpAccountNode = [NSString stringWithUTF8String:account];
	
	id object = 0;

	for (int i = 0;i < accountDeviceList->count();i++)
	{
		string acc = ((NSString*)object)->UTF8String();
		unsigned char decAcc[1024] = {0};

		simpleDecode((const unsigned char*)acc.c_str(),decAcc);

		if (tmpAccountNode->isEqual(NSString::stringWithUTF8String((const char*)decAcc)))
		{
			return true;
		}
	}

// 	while ((object = [enumerator nextObject]) != nil)
// 	{
// 		string acc = [(NSString*)object UTF8String];
// 		
// 		unsigned char decAcc[1024] = {0x00};
// 		simpleDecode((const unsigned char*)acc.c_str(), decAcc);
// 		
// 		if ([tmpAccountNode isEqual:[NSString stringWithUTF8String:(const char*)decAcc]]) 
// 		{
// 			return true;
// 		}
// 	}
	
	return false;
}

void NDDataPersist::SaveAccountDeviceList()
{
	//[accountDeviceList writeToFile:this->GetAccountDeviceListPath() atomically:YES];
}

void NDDataPersist::SetGameSetting(GAME_SETTING type, bool bOn)
{
	if (bOn) 
	{
		s_gameSetting |= type;
	} 
	else
	{
		s_gameSetting &= ~type;
	}
}

bool NDDataPersist::IsGameSettingOn(GAME_SETTING type)
{
	return NDDataPersist::s_gameSetting & type;
}

void NDDataPersist::SaveGameSetting()
{
	NSString* strGameSetting = NSString::stringWithFormat("%d",s_gameSetting);

	NSString* strTemp = new NSString(kGameSetting);
	SetData(kGameSettingData,strTemp,strGameSetting->UTF8String());
	SaveData();

	/***
	* 以下为旧代码 郭浩
	*/
// 	NSString* strGameSetting = [NSString stringWithFormat:@"%d", s_gameSetting];
// 	this->SetData(kGameSettingData, kGameSetting, [strGameSetting UTF8String]);
// 	this->SaveData();
}

///////////////////////////////////////
//邮件数据plist

const NSUInteger max_player_save_count = 5;
const NSUInteger max_mail_save_count = 20;

//NDEmailDataPersist* NDEmailDataPersist::s_intance = NULL;
//
//NDEmailDataPersist::NDEmailDataPersist()
//{
//	NDAsssert(s_intance == NULL);
//	LoadEmailData();
//}
//
//NDEmailDataPersist::~NDEmailDataPersist()
//{
//	SaveEmailData();
//	
//	if (emailArray) 
//	{
//		[emailArray release];
//		emailArray = nil;
//	}
//}
//
//NDEmailDataPersist& NDEmailDataPersist::DefaultInstance()
//{
//	if (s_intance == NULL) 
//	{
//		s_intance =  new NDEmailDataPersist;
//	}
//	
//	return *s_intance;
//}
//
//void NDEmailDataPersist::Destroy()
//{
//	if (s_intance != NULL) 
//	{
//		delete s_intance;
//		s_intance = NULL;
//	}
//}
//
//string NDEmailDataPersist::GetEmailState(int playerid,string mail)
//{
//	if (mail.empty()) 
//	{
//		return "";
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		return "";
//	}
//	
//	NSString *nsStr= [playermail objectForKey:[NSString stringWithUTF8String:mail.c_str()]];
//	if (nsStr == nil) {
//		return "";
//	}
//	
//	return [nsStr UTF8String];
//}
//
//void NDEmailDataPersist::AddEmail(int playerid,string mail, string state)
//{
//	if (mail.empty()) 
//	{
//		return;
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		if ([dic count] > max_player_save_count) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				
//				[dic removeObjectForKey:key];
//				break;
//			}
//			
//		}
//		playermail = [[NSMutableDictionary alloc] init];
//		[dic setObject:playermail forKey:strPlayer];
//		[playermail release];
//	}
//	
//	if ([playermail count] > max_mail_save_count) {
//		NSEnumerator *enumerator;
//		enumerator = [playermail keyEnumerator];
//		id key;
//		while ((key = [enumerator nextObject]) != nil) {
//			
//			[playermail removeObjectForKey:key];
//			break;
//		}
//		
//	}
//	
//	[playermail setObject:[NSString stringWithUTF8String:state.c_str()]
//				forKey:[NSString stringWithUTF8String:mail.c_str()]];
//
//}
//
//void NDEmailDataPersist::DelEmail(int playerid,string mail)
//{
//	if (mail.empty()) 
//	{
//		return;
//	}
//	
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerid];
//	NSMutableDictionary *playermail = [dic objectForKey:strPlayer];
//	if (playermail == nil) {
//		return;
//	}
//	
//	[playermail removeObjectForKey:[NSString stringWithUTF8String:mail.c_str()]];
//}
//
//void NDEmailDataPersist::LoadEmailData()
//{
//	NSString* filePath = GetEmailPath();
//	if (!filePath) 
//	{
//		emailArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		emailArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		emailArray = [[NSMutableArray alloc] init];
//	}
//	
//}
//
//void NDEmailDataPersist::SaveEmailData()
//{
//	NSString* filePath = GetEmailPath();
//	if (filePath) 
//	{
//		[emailArray writeToFile:filePath atomically:YES];
//	}
//	
//	[emailArray release];
//	emailArray = nil;
//}
//
//NSString* NDEmailDataPersist::GetEmailPath()
//{
//	NSString* dir = [kEmailFileName stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kEmailFileName;
////	if (!file) 
////	{
////		return nil;
////	}
////	
////	NSArray *paths = NSSearchPathForDirectoriesInDomains( 
////														 NSDocumentDirectory, NSUserDomainMask, YES); 
////	NSString *documentsDirectory = [paths objectAtIndex:0]; 
////	return [documentsDirectory stringByAppendingPathComponent:file];
//}
//
//NSMutableDictionary* NDEmailDataPersist::LoadMailDiction()
//{
//	NDAsssert(emailArray != nil);
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([emailArray count] > 0) {
//		NDAsssert([emailArray count] == 1);
//		dic = (NSMutableDictionary*)[emailArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // 数据不存在,初始化
//			dic = [[NSMutableDictionary alloc] init];
//			[emailArray addObject:dic];
//			[dic release];
//	}
//	
//	return dic;
//}

//quick talk data

//NDQuickTalkDataPersist::NDQuickTalkDataPersist()
//{
//	this->LoadQuickTalkData();
//}
//
//NDQuickTalkDataPersist::~NDQuickTalkDataPersist()
//{
//	this->SaveQuickTalkData();
//	[quickTalkArray release];
//}
//
//NDQuickTalkDataPersist& NDQuickTalkDataPersist::DefaultInstance()
//{
//	static NDQuickTalkDataPersist obj;
//	return obj;
//}
//
//void NDQuickTalkDataPersist::GetAllQuickTalkString(int idPlayer, vector<string>& vMsg)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	
//	// 没有该玩家的快捷聊天记录，新建
//	if (arrMsg == nil) {
//		if ([dic count] >= QT_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arrMsg = [[NSMutableArray alloc] initWithObjects:
//				  kSysQuickTalk1, kSysQuickTalk2, kSysQuickTalk3, kSysQuickTalk4, kSysQuickTalk5, 
//				  @"", @"", @"", @"", @"", 
//				  nil];
//		
//		[dic setObject:arrMsg forKey:strPlayer];
//		[arrMsg release];
//		
//		this->SaveQuickTalkData();
//	}
//	
//	for (NSUInteger i = 0; i < [arrMsg count]; i++) {
//		NSString* msg = (NSString*)[arrMsg objectAtIndex:i];
//		vMsg.push_back(string([msg UTF8String]));
//	}
//}
//
//string NDQuickTalkDataPersist::GetQuickTalkString(int idPlayer, uint uIdx)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	
//	string str;
//	
//	if (uIdx < [arrMsg count]) {
//		str = [(NSString*)[arrMsg objectAtIndex:uIdx] UTF8String];
//	}
//	
//	return str;
//}
//
//void NDQuickTalkDataPersist::SetQuickTalkString(int idPlayer, uint uIdx, const string& msg)
//{
//	NSMutableDictionary* dic = this->LoadQuickTalkDiction();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arrMsg = [dic objectForKey:strPlayer];
//	if (uIdx < [arrMsg count]) {
//		[arrMsg replaceObjectAtIndex:uIdx withObject:[NSString stringWithUTF8String:msg.c_str()]];
//		this->SaveQuickTalkData();
//	}
//}
//
//void NDQuickTalkDataPersist::LoadQuickTalkData()
//{
//	NSString* filePath = this->GetQuickTalkPath();
//	if (!filePath) 
//	{
//		quickTalkArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		quickTalkArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		quickTalkArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDQuickTalkDataPersist::SaveQuickTalkData()
//{
//	NSString* filePath = this->GetQuickTalkPath();
//	if (filePath) 
//	{
//		[quickTalkArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSString* NDQuickTalkDataPersist::GetQuickTalkPath()
//{
//	NSString* dir = [kQuickTalkFileName stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kQuickTalkFileName;
//}
//
//NSMutableDictionary* NDQuickTalkDataPersist::LoadQuickTalkDiction()
//{
//	NSMutableDictionary* dic = nil;
//	
//	if ([quickTalkArray count] > 0) {
//		NDAsssert([quickTalkArray count] == 1);
//		dic = (NSMutableDictionary*)[quickTalkArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // 数据不存在,初始化
//		dic = [[NSMutableDictionary alloc] init];
//		[quickTalkArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//// 物品栏配置
//// 循环位移，用于物品id加密
//unsigned int _rotl(unsigned int value, int shift) {
//	if ((shift &= 31) == 0) {
//		return value;
//	}
//	return (value << shift) | (value >> (32 - shift));
//}
//
//unsigned int _rotr(unsigned int value, int shift) {
//	if ((shift &= 31) == 0) {
//		return value;
//	}
//	return (value >> shift) | (value << (32 - shift));
//}
//
//NDItemBarDataPersist::NDItemBarDataPersist()
//{
//	this->LoadData();
//}
//
//NDItemBarDataPersist::~NDItemBarDataPersist()
//{
//	this->SaveData();
//	[itemBarArray release];
//}
//
//NDItemBarDataPersist& NDItemBarDataPersist::DefaultInstance()
//{
//	static NDItemBarDataPersist obj;
//	return obj;
//}
//
//void NDItemBarDataPersist::GetItemBarConfigInBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
//{
//	NSMutableDictionary* dic = this->LoadDictionInBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	// 没有该玩家的物品栏记录，新建
//	if (arr == nil) {
//		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arr = [[NSMutableArray alloc] init];
//		
//		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		[dic setObject:arr forKey:strPlayer];
//		[arr release];
//		
//		this->SaveData();
//	}
//	
//	for (NSUInteger i = 0; i < [arr count]; i++) {
//		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
//		int idItemType = _rotl([num unsignedIntValue], kIDShift);
//		if (idItemType >= 0) {
//			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
//		}
//	}
//}
//
//void NDItemBarDataPersist::GetItemBarConfigOutBattle(int idPlayer, vector<ItemBarCellInfo>& vCellInfo)
//{
//	NSMutableDictionary* dic = this->LoadDictionOutBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	// 没有该玩家的物品栏记录，新建
//	if (arr == nil) {
//		if ([dic count] >= IB_MAX_PLAYER_SAVE_NUM) {
//			NSEnumerator *enumerator;
//			enumerator = [dic keyEnumerator];
//			id key;
//			while ((key = [enumerator nextObject]) != nil) {
//				[dic removeObjectForKey:key];
//				break;
//			}
//		}
//		
//		arr = [[NSMutableArray alloc] init];
//		
//		for (NSUInteger i = 0; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		[dic setObject:arr forKey:strPlayer];
//		[arr release];
//		
//		this->SaveData();
//	}
//	
//	if ([arr count] < IB_MAX_ITEM_NUM_OUT_BATTLE)
//	{
//		NSUInteger i = [arr count];
//		for (; i < IB_MAX_ITEM_NUM_OUT_BATTLE; i++) {
//			[arr addObject:[NSNumber numberWithInt:0]];
//		}
//		
//		this->SaveData();
//	}
//	
//	for (NSUInteger i = 0; i < [arr count]; i++) {
//		NSNumber* num = (NSNumber*)[arr objectAtIndex:i];
//		int idItemType = _rotl([num unsignedIntValue], kIDShift);
//		if (idItemType >= 0) {
//			vCellInfo.push_back(ItemBarCellInfo(idItemType, i));
//		}
//	}
//}
//
//void NDItemBarDataPersist::SetItemAtIndexInBattle(int idPlayer, uint uIdx, int idItemtype)
//{
//	NSMutableDictionary* dic = this->LoadDictionInBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	if (uIdx < [arr count]) {
//		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
//		this->SaveData();
//	}
//}
//
//void NDItemBarDataPersist::SetItemAtIndexOutBattle(int idPlayer, uint uIdx, int idItemtype)
//{
//	NSMutableDictionary* dic = this->LoadDictionOutBattle();
//	NDAsssert(nil != dic);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", idPlayer];
//	NSMutableArray *arr = [dic objectForKey:strPlayer];
//	
//	if (uIdx < [arr count]) {
//		[arr replaceObjectAtIndex:uIdx withObject:[NSNumber numberWithInt:_rotr(idItemtype, kIDShift)]];
//		this->SaveData();
//	}
//}
//
//void NDItemBarDataPersist::LoadData()
//{
//	NSString* filePath = this->GetPath();
//	if (!filePath) 
//	{
//		itemBarArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		itemBarArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		itemBarArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDItemBarDataPersist::SaveData()
//{
//	NSString* filePath = this->GetPath();
//	if (filePath) 
//	{
//		[itemBarArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSString* NDItemBarDataPersist::GetPath()
//{
//	NSString* dir = [kItemBarFileName stringByDeletingLastPathComponent];
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	return kItemBarFileName;
//}
//
//NSMutableDictionary* NDItemBarDataPersist::LoadDictionOutBattle()
//{
//	NSMutableDictionary* dic = nil;
//	
//	if ([itemBarArray count] > 0) {
//		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // 数据不存在,初始化
//		dic = [[NSMutableDictionary alloc] init];
//		[itemBarArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//NSMutableDictionary* NDItemBarDataPersist::LoadDictionInBattle()
//{
//	this->LoadDictionOutBattle();
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([itemBarArray count] > 1) {
//		dic = (NSMutableDictionary*)[itemBarArray objectAtIndex:1];
//	}
//	
//	if (dic == nil) { // 数据不存在,初始化
//		NDAsssert([itemBarArray count] == 1);
//		dic = [[NSMutableDictionary alloc] init];
//		[itemBarArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//
//#pragma mark plist 基本操作
////通过LoadMailDiction调用获取数据字典,数据字典可加入object-c数据对象,数据保存与加载在构造与析构中自动完成
//
//NDDataPlistBasic::NDDataPlistBasic(string filename)
//{
//	dataArray = nil;
//	
//	m_filename = filename;
//	
//	LoadData();
//}
//
//NDDataPlistBasic::~NDDataPlistBasic()
//{
//	SaveData();
//	
//	[dataArray release];
//	dataArray = nil;
//}
//
//NSString* NDDataPlistBasic::GetPath(string filename)
//{
//	NSString* name = [NSString stringWithFormat:@"%@%s.plist", DataFilePath(), filename.c_str()];
//	NSString* dir = [name stringByDeletingLastPathComponent] ;
//	if (!KDirectory::isDirectoryExist([dir UTF8String])) 
//	{
//		if (!KDirectory::createDir([dir UTF8String]))
//		{
//			return nil;
//		}
//	}
//	
//	return name;
//}
//
//void NDDataPlistBasic::LoadData()
//{
//	NSString* filePath = GetPath(m_filename);
//	if (!filePath) 
//	{
//		dataArray = [[NSMutableArray alloc] init];
//		return;
//	}
//	
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//	{ 
//		dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
//	}
//	else
//	{
//		dataArray = [[NSMutableArray alloc] init];
//	}
//}
//
//void NDDataPlistBasic::SaveData()
//{
//	NSString* filePath = GetPath(m_filename);
//	if (filePath && dataArray) 
//	{
//		[dataArray writeToFile:filePath atomically:YES];
//	}
//}
//
//NSMutableDictionary* NDDataPlistBasic::LoadMailDiction()
//{
//	NDAsssert(dataArray != nil);
//	
//	NSMutableDictionary* dic = nil;
//	
//	if ([dataArray count] > 0) {
//		NDAsssert([dataArray count] == 1);
//		dic = (NSMutableDictionary*)[dataArray objectAtIndex:0];
//	}
//	
//	if (dic == nil) { // 数据不存在,初始化
//		dic = [[NSMutableDictionary alloc] init];
//		[dataArray addObject:dic];
//		[dic release];
//	}
//	
//	return dic;
//}
//
//
//#pragma mark 玩家提交bug
//// NDQuestionDataPlist负责保存玩家提问数据(玩家每天最多提10个问题)
//#define MAX_QUEST_BUG_COUNT_PER_DAY (10)
//#define PER_DAY_SECOND (3600 * 24)
//
//NDQuestionDataPlist::NDQuestionDataPlist() : 
//NDDataPlistBasic("questbug")
//{
//}
//
//NDQuestionDataPlist::~NDQuestionDataPlist()
//{
//}
//
//bool NDQuestionDataPlist::CanPlayerQuestCurrentDay(int playerId)
//{
//	return !IsOverCount(GetPlayerCurQuestCount(playerId));
//}
//
//void NDQuestionDataPlist::AddPlayerQuest(int playerId)
//{
//	IncPlayerQuestCount(playerId);
//}
//
//int NDQuestionDataPlist::GetPlayerCurTime(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return 0;
//	
//	NSNumber *num = [quest objectAtIndex:0];
//	
//	if (!num) return 0;
//	
//	return [num floatValue];
//}
//
//bool NDQuestionDataPlist::IsOverTime(double time)
//{
//	double cur = [NSDate timeIntervalSinceReferenceDate];
//	if ( int(cur - time) > PER_DAY_SECOND)
//		return true;
//		
//	return false;
//}
//
//int NDQuestionDataPlist::GetPlayerCurQuestCount(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return 0;
//	
//	NSNumber *num = [quest objectAtIndex:1];
//	
//	if (!num) return 0;
//	
//	return [num intValue];
//}
//
//bool NDQuestionDataPlist::IsOverCount(int count)
//{
//	if (count >= MAX_QUEST_BUG_COUNT_PER_DAY)
//		return true;
//		
//	return false;
//}
//
//NSMutableArray* NDQuestionDataPlist::GetQuestData(int playerId)
//{
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
//	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
//	
//	if (playerQuest == nil) {
//		NSMutableArray *quest = [[NSMutableArray alloc] init];
//		[quest addObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]]];
//		[quest addObject:[NSNumber numberWithInt:0]];
//		
//		[dic setObject:quest forKey:strPlayer];
//		
//		[quest release];
//	}
//	
//	playerQuest = [dic objectForKey:strPlayer];
//	
//	NSNumber *num = [playerQuest objectAtIndex:0];
//	
//	if (IsOverTime([num doubleValue]))
//	{
//		ResetPlayerQuest(playerId);
//	}
//	
//	return [dic objectForKey:strPlayer];
//}
//
//void NDQuestionDataPlist::ResetPlayerQuest(int playerId)
//{
//	NSMutableDictionary *dic = this->LoadMailDiction();
//	NDAsssert(dic != nil);
//	
//	NSString *strPlayer= [NSString stringWithFormat:@"%d", playerId];
//	NSMutableArray *playerQuest = [dic objectForKey:strPlayer];
//	
//	if (playerQuest != nil) {
//		[dic removeObjectForKey:strPlayer];
//		
//		GetQuestData(playerId);
//	}
//}
//
//void NDQuestionDataPlist::IncPlayerQuestCount(int playerId)
//{
//	NSMutableArray* quest = GetQuestData(playerId);
//	
//	if (quest == nil) return;
//	
//	NSNumber *num = [quest objectAtIndex:1];
//	
//	if (num == nil)
//		return;
//	
//	[quest replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[num intValue]+1]];
//	
//	this->SaveData();
//}
//
