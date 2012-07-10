/*
 *  MsgBase.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MsgBase.h"
#include "NDMsgDefine.h"
#include "AllMsg.h"
#include "define.h"

typedef map<unsigned short, CMsgBase*> MSG_TABLE_TYPE;

#define MAKE_PAIR(ID, VALUE)	MSG_TABLE_TYPE::value_type(ID, new VALUE)
#define REG_MSG(ID, VALUE)		((m_MsgPool.insert(MAKE_PAIR(ID, VALUE))).first)->second
#define CASE_VALUE(ID, VALUE)	case ID: \
{	CMsgBase * p = REG_MSG(ID, VALUE);	return p; }


map<unsigned short, CMsgBase*> CNetMsgPool::m_MsgPool;
bool CNetMsgPool:: m_bDestroy = false;
bool CNetMsgPool:: m_bFirstStart = true;

void CNetMsgPool::AssureStaticHelperOrder()
{
	static NetMsgDestroyHelper g_DestroyHelper;//只是用来帮助销毁的类，在析构函数中帮助销毁
}

CNetMsgPool::~CNetMsgPool()
{
	UnRegisterNetNsg();
	m_MsgPool.clear();	
}
CNetMsgPool::CNetMsgPool()
{
}

void CNetMsgPool::DestroyMsgPool()
{
	if(m_bFirstStart)	//还没使用过MAP对象就返回，不需要销毁
	{
		m_bFirstStart = true;
		return;
	}
	m_bDestroy = true;
	UnRegisterNetNsg();
	m_MsgPool.clear();
}

CMsgBase* CNetMsgPool::GetNetMsg(unsigned short ID,int pkgsize)
{
	if(m_bFirstStart)
	{
		AssureStaticHelperOrder();
		m_bFirstStart = false;
	}
	//已经销毁不能再注册消息了
	if(m_bDestroy)
	{
		return NULL;
	}
	
	CMsgBase* pNetMsg = NULL;
	pNetMsg = Lookup(ID,pkgsize);
	pNetMsg = (pNetMsg != NULL) ? pNetMsg : RegistNetMsg(ID,pkgsize);
	
	return (pNetMsg != NULL) ? pNetMsg : NULL;
}

CMsgBase* CNetMsgPool::Lookup(unsigned short ID,int pkgsize)
{
	MSG_TABLE_TYPE::iterator finded = m_MsgPool.find(ID);
	if(finded != m_MsgPool.end())
	{
		return finded->second;
	}
	return NULL;
}

void CNetMsgPool::UnRegisterNetNsg()
{
	MSG_TABLE_TYPE::iterator i = m_MsgPool.begin();
	while(i != m_MsgPool.end())
	{
		delete (*i).second;
		i++;
	}
}

CMsgBase* CNetMsgPool::RegistNetMsg(unsigned short ID,int pkgsize)
{
	switch(ID)
	{
			CASE_VALUE(_MSG_LOGIN,						CMsgBillboard)
	}
	return NULL;
}


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CMsgBase::CMsgBase()
{
	Init();
}

CMsgBase::~CMsgBase()
{
	
}

//////////////////////////////////////////////////////////////////////
void CMsgBase::Init()
{
	memset(m_bufMsg, 0L, sizeof(m_bufMsg));
	m_unMsgSize	=0;
	m_unMsgType	=_MSG_NONE;
}

//////////////////////////////////////////////////////////////////////
bool CMsgBase::IsValid(void)
{
	if(_MSG_NONE == this->GetType())
		return false;
	
	return true;
}

//////////////////////////////////////////////////////////////////////
bool CMsgBase::Create(char* pbufMsg, unsigned long dwMsgSize)
{
	if(!pbufMsg)
		return false;
	
	if((unsigned short)dwMsgSize != GetSize(pbufMsg, dwMsgSize))
		return false;
	
	if(_MSG_NONE == GetType(pbufMsg, dwMsgSize))
		return false;
	
	memcpy(this->m_bufMsg, pbufMsg, dwMsgSize);
	return true;
}

//////////////////////////////////////////////////////////////////////
void CMsgBase::Process(void *pInfo)
{
	//--------------------
	//char szMsg[1024];
//	sprintf(szMsg, "Process Msg:%d, Size:%d", m_unMsgType, m_unMsgSize);
//	::LogMsg(szMsg);	
	return;
}

//////////////////////////////////////////////////////////////////////
void CMsgBase::Send(void)
{	
}

//////////////////////////////////////////////////////////////////////
// static functions;
//////////////////////////////////////////////////////////////////////
unsigned short	CMsgBase::GetType(char* pbufMsg, unsigned long dwMsgSize)
{
	// check it...
	NDAsssert(pbufMsg);
	NDAsssert((int)dwMsgSize <= CMsgBase::GetMaxSize());
	
	unsigned short* pUnShort	=(unsigned short* )pbufMsg;
	return pUnShort[1];
}

//////////////////////////////////////////////////////////////////////
unsigned short	CMsgBase::GetSize(char* pbufMsg, unsigned long dwMsgSize)
{
	// check it...
	NDAsssert(pbufMsg);
	NDAsssert((int)dwMsgSize <= CMsgBase::GetMaxSize());
	
	unsigned short* pUnShort	=(unsigned short* )pbufMsg;
	return pUnShort[0];
}

//////////////////////////////////////////////////////////////////////
CMsgBase* CMsgBase::CreateMsg(char* pbufMsg, unsigned long dwMsgSize)
{
	// check it...
	if(!pbufMsg || (int)dwMsgSize > GetMaxSize())
		return NULL;
	
	NDAsssert((int)dwMsgSize == CMsgBase::GetSize(pbufMsg, dwMsgSize));
	
	CMsgBase* pMsg	=NULL;
	const unsigned short usType = CMsgBase::GetType(pbufMsg,dwMsgSize);
	
	pMsg = CNetMsgPool::GetNetMsg(usType,dwMsgSize);
	
	if(!pMsg)
		return NULL;
		
	if(!pMsg->Create(pbufMsg, dwMsgSize))
	{
		SAFE_DELETE(pMsg);
		return NULL;
	}
	
	return pMsg;
}
