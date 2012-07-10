#pragma once

/*
封装简单的网络库应用
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/

#ifndef __NETFACTORY__HEAD__FILE__
#define __NETFACTORY__HEAD__FILE__

#include <vector>
#ifdef ANDROID
#include <sys/select.h>
#endif
#include "Socket.h"
#include "TcpSocket.h"
#include "HTTPSocket.h"
#include "HttpPostSocket.h"
#include "HttpPutSocket.h"
#include "HttpGetSocket.h"
#include "MySemaphore.h"
#include "SocketHandler.h"
#include "BaseType.h"

//本接口为网络客户端回调事件，
//pSocket参数为触发当前数据的SOCKET对象指针
class INetEvnet
{
public:
	//客户端连接成功时，回调本函数
	virtual void OnConnect(Socket* pSocket){};

	//客户端连接失败时，回调本函数
	virtual void OnConnectFailed(Socket* pSocket){};

	//客户端连接失败时，进行重连时，回调本函数，如果返回ture则重连，如果返回false则不重连。
	virtual bool OnConnectRetry(Socket* pSocket){return true;};

	virtual void OnReconnect(Socket* pSocket){};

	//客户端连接超时，回调本函数
	virtual void OnConnectTimeout(Socket* pSocket){};

	//客户端连接断开时，回调本函数
	virtual void OnDisconnect(Socket* pSocket){};

	//客户端接收到数据时，回调本函数，本接口接收的是TCP层次的数据。
	//注意：如果为HTTP连接，则先会回调本函数，再回调OnData类函数，本函数收到的数据包含HTTP头
	virtual void OnRawData(Socket* pSocket, const char *buf, size_t n){};

	//客户端接收到数据时，回调本函数，本接口接收的是HTTP层次的数据。
	//注意：本接口接到的数据为HTTP的内容，不包括HTTP头数据。
	virtual void OnData(Socket* pSocket, const char *buf, size_t n){};

	//客户端接收数据完毕时，回调本函数，本接口接收的是HTTP层次的数据。
	virtual void OnDataComplete(Socket* pSocket){};

	//客户端数据所有的数据缓冲发送完成后，回调本函数
	virtual void OnWriteComplete(Socket* pSocket){};

	~INetEvnet(){};
};

//数据压缩、解压类
//本类主要用于有部分网络数据可能会用gZip的压缩算法进行传输。
class CZipData
{
public:
	
	//压缩数据，成功返回0，非0则失败
	static int ZipCompress(BYTE* pData/*待压缩的源数据*/, ULONG lDataLen/*数据长度*/,	BYTE* pZipData/*压缩后的数据*/, ULONG* pZipDataLen/*输入为pZipData长度，输出为压缩后的数据长度*/);

	//压缩数据，成功返回0，非0则失败，一般用于HTTP协议，如果HTTP包头为：Content-Encoding: gzip
	static int gZipcompress(BYTE* pData/*待压缩的源数据*/, ULONG lDataLen/*数据长度*/, BYTE* pZipData/*压缩后的数据*/, ULONG* pZipDataLen/*输入为pZipData长度，输出为压缩后的数据长度*/);
	
	//解压数据，成功返回0，非0则失败
	static int ZipUnCompress(BYTE* pZipData/*待解压的数据*/, ULONG nZipDataLen/*数据长度*/, BYTE *pData/*解压后的数据*/, ULONG *pDataLen/*输入为pData长度，输出为压缩后的数据长度*/);

	//解夺数据，成功返回0，非0则失败，一般用于HTTP协议，如果HTTP包头为：Content-Encoding: gzip
	static int gZipUnCompress(BYTE* pZipData/*待解压的数据*/, ULONG nZipDataLen/*数据长度*/, BYTE *pData/*解压后的数据*/, ULONG *pDataLen/*输入为pData长度，输出为压缩后的数据长度*/);
};

class CNetFactory : Thread
{
public:

	//网络管理类单实例引用
	static CNetFactory& sharedInstance();

	//创建一个TCP连接的SOCKET
	TcpSocket* CreateTcpSocket(INetEvnet* pEvent);

	//创建一个原始的HTTP连接的SOCKET
	//HTTPSocket*	CreateHttpSocket(INetEvnet* pEvent);

	//创建一个Post方式的HTTP连接的SOCKET
	HttpPostSocket* CreateHttpPostSocket(INetEvnet* pEvent);

	//创建一个Put方式的HTTP连接的SOCKET
	HttpPutSocket* CreateHttpPutSocket(INetEvnet* pEvent);

	//创建一个Get方式的HTTP连接的SOCKET
	HttpGetSocket* CreateHttpGetSocket(INetEvnet* pEvent);

	//释放前面接口创建的对象实例
	bool ReleaseSocket(Socket* pSocket);

	//开启网络处理线程，一般在初始化处调一次即可。
	//如果没有调用本接口，添加到Pool里的SOCKET，将不会被处理，即不会进行数据接收。
	bool Start();

	//创建各类SOCKET后，可以对SOCKET进行设置，设置完后，通过本接口托管SOCKET进行数据接收处理。
	bool AddSocketToPool(Socket* pSocket);

	//取消数据接收托管。
	bool RemoveSocketFromPool(Socket* pSocket);

	//取消数据接收托管,并释放对象
	bool ReleaseSocketFromPool(Socket* pSocket);

	//关闭网络处理线程，一般在程序退出时调用一次即可。
	//调用本接口后，在Pool里的SOCKET，将不会再被处理，即不会进行数据接收。
	bool Stop();
	
	//内部实现，用户不要调用。
	SocketHandler& GetSocketHandler();
private:
	CNetFactory(void);
	~CNetFactory(void);
	
protected:
	virtual void Run();

protected:
	
	typedef struct 
	{
		Socket* pSocket;
		int nFlag;
	}SOCKOPINFO;
	typedef std::vector<SOCKOPINFO> SOCKETOPINFOARR;

	SOCKETOPINFOARR	m_arrSockOpInfo;
	Mutex		m_objMutex;

	Semaphore		m_objSemaphore;
	SocketHandler	m_objSockethandler;
};

#endif