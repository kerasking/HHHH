/*
 *  MsgBase.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MSG_BASE_H_
#define _MSG_BASE_H_

#define _MAX_MSGSIZE (1046)

#include <map>

using namespace std;
class CMsgBase;

class CNetMsgPool
{
public:
	static CMsgBase* GetNetMsg(unsigned short ID,int pkgsize);	//首先从消息池中查找消息查不到就注册此消息并返回
	static void DestroyMsgPool();
private:
	static void	UnRegisterNetNsg();
	static CMsgBase* RegistNetMsg(unsigned short ID,int pkgsize);
	static CMsgBase* Lookup(unsigned short ID,int pkgsize);
	static void	AssureStaticHelperOrder();
	static map<unsigned short, CMsgBase*> m_MsgPool;
	static bool m_bDestroy;
	static bool	m_bFirstStart;	//如果是第一次开启这个类那么就生成 NetMsgDestroyHelper 对象
private:
	CNetMsgPool();	//不允许产生实例--------只使用静态方法，此类就相当于一个全局查找表的作用
	~CNetMsgPool();				
};

//这个是用来帮助销毁MSGPOOL的类
class NetMsgDestroyHelper
{
	friend class CNetMsgPool;
private:
	NetMsgDestroyHelper(){}
public:
	~NetMsgDestroyHelper(){ CNetMsgPool::DestroyMsgPool(); }		//这个最终会被调用的
};

////////////////////////////////////////////

class CMsgBase
{
public:
	CMsgBase();
	virtual ~CMsgBase();
	
	void	Init();
	void	Reset(void)	{Init();}
	
	const unsigned short	GetType	(void)		{return m_unMsgType;}
	const unsigned short	GetSize	(void)		{return m_unMsgSize;}
	
	char*	GetBuf(void)	{return m_bufMsg;}
	
public:	
	virtual bool			Create		(char* pMsgBuf, unsigned long dwSize);
	virtual bool			IsValid		(void);
	void	Send			(void);
	virtual void			Process		(void *pInfo);
	
public:
	static int	GetMaxSize	(void)		{return _MAX_MSGSIZE;}
	static unsigned short	GetType		(char* pbufMsg, unsigned long dwMsgSize);
	static unsigned short	GetSize		(char* pbufMsg, unsigned long dwMsgSize);
	
	static CMsgBase*	CreateMsg	(char* pbufMsg, unsigned long dwMsgSize);
	
	
protected:
	union 
	{
		char	m_bufMsg[_MAX_MSGSIZE];
		struct 
		{
			unsigned short	m_unMsgSize;
			unsigned short	m_unMsgType;
		};
	};
};

#endif // _MSG_BASE_H_