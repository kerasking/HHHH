/*
 *  NDMsgLogin.cpp
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-27.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgLogin.h"
#include "NDMsgDefine.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
//#include "DESedeEngine.h"
//#include "CBCBlockCipher.h"
#include "Des.h"

#include <vector>
#include "NDMapMgr.h"

/*
 server06 "lyol4"
 tcp0802 "tqnd780924"
 1 "123456789" 
 */


//static std::string username = "sj62312017";//"tcp0801";//"sj18140768";
//static std::string password = "123456789";//"1";//
static std::string servername = "lyol4";//"server02";

static std::string phoneKey;
static std::string serverPhoneKey;

void NDMsgLogin::Process(NDTransData* data, int len)
{
	if (!data) return;
	

	if (!data->decrypt(phoneKey))
	{
		NSLog(@"解密失败,NDMsgLogin::Process");
		return;
	}
	
	len = data->GetSize()-6;
	
	srandom(time(NULL));
	int nRandNum = random()%16 +1; //1~16
	
	NSMutableString *str = [[NSMutableString alloc] init];
	for (int i = 1; i <= nRandNum; i++) { // 产生 a-z的随机串
		NSString *sb = [NSString stringWithFormat:@"%c", (char) ((random()%100 +1) % 26 + 97)];
		[str appendString:sb];
	}
	
	
	char buf[1024] = {0x00};
	data->Read((unsigned char*)buf, len);

	for (int i=0; i < len; i++) {
		serverPhoneKey.push_back(buf[i]);
	} 


	NDTransData senddata;
	
	senddata.WriteShort(NDServerCode::LOGIN);
	senddata.WriteUnicodeString(NDMapMgrObj.GetUserName());
	senddata.WriteUnicodeString(NDMapMgrObj.GetPassWord());
	//senddata.WriteUnicodeString(username);
	//senddata.WriteUnicodeString(password);
	senddata.WriteUnicodeString(servername);
	senddata.WriteShort([str length]);
	senddata.Write((unsigned char*)[str UTF8String], [str length]);
	
	if ( !senddata.encrypt(serverPhoneKey) )
	{
		NSLog(@"消息发送加密失败,NDMsgLogin::Process");
		return;
	}
	
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&senddata);	
	
}

void NDMsgLogin::generateClientKey() 
{
	// ------ 产生随机key ------
	srandom(time(NULL));
	NSString *sb = [NSString stringWithFormat:@"%d",(int)[NSDate timeIntervalSinceReferenceDate]]; 
	NSMutableString *str = [[NSMutableString alloc] init];
	[str appendString:sb];
	for (int i = [str length]; i < 24; i++) { // 产生 a-z的随机串
		NSString *sb = [NSString stringWithFormat:@"%c", (char) ((random()%100 +1) % 26 + 97)];
		[str appendString:sb];
	}
	phoneKey.clear();
	for (int i = 0; i < 24; i++)
	{
		unichar c = [str characterAtIndex:i];
		phoneKey.push_back((char)c);
	}	
	[str release];
}

/** 交换密钥 */
void NDMsgLogin::sendClientKey() 
{
	NDTransData data;
	
	int version = 0;
	data << (unsigned short)NDServerCode::MB_LOGINSYSTEM_NORSA_EXCHANGE_KEY << version;
	data.Write((unsigned char*)(phoneKey.c_str()), phoneKey.size());
	//NSLog(@"随机生成的key%s", (unsigned char*)(phoneKey.c_str() ));
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
}