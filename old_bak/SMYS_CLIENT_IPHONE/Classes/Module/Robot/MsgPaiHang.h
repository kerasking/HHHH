/*
 *  MsgPaiHang.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef _MSG_PAI_HANG_H_
#define _MSG_PAI_HANG_H_

#include "MsgBase.h"

class CMsgBillboard : public CMsgBase
{
public:
	CMsgBillboard();
	virtual ~CMsgBillboard();
	
#pragma pack(push, 1)
public:
	typedef struct
	{
		unsigned short unMsgSize;
		unsigned short unMsgType;
		
		union
		{
			unsigned int uCount;			// 下发排行榜个数
			int idBillboard;		// 上发要查排行榜的id
		};
		
		// OBJID id;				// 排行榜id
		// MBStr userName;			// 排行榜名字
		
		// int nQueryPage;			// 上发要查询的页数, 首次查询发-1
	}MSG_Info;
#pragma pack(pop)
	
public:
	bool Append(int id, const string& strName);
	int GetCount() { return m_pInfo ? m_pInfo->uCount : 0; }
	
public:
	virtual bool	Create	(char* pBuf, unsigned short usBufLen);
	virtual void	Process	(int idActor);
	
private:
	MSG_Info* m_pInfo;
};

#endif //_MSG_PAI_HANG_H_