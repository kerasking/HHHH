#ifndef __KT_FTP_CLIENT_H
#define __KT_FTP_CLIENT_H

#include <list>
#include "KData.h"
#include "KTcpClientSocket.h"

typedef void (*FTP_TRANS_CALLBACK)( unsigned int progress, void* param );

struct FtpFileItem
{
	KData name;
	bool bDir;
	int fileLen;
};

class KFtpClient
{
public:
	KFtpClient(void);
	~KFtpClient(void);
	bool connect( const KData& server, short port );
	bool login( const KData& user, const KData& pasw );
	bool mkdir( const KData& dir );
	bool chdir( const KData& dir );
	bool ftpCmd( const KData& cmd, char ch );
	void setTimeout( long millsec );
	bool getFile( const KData& localFile, const KData& remoteFile );
	bool putFile(const KData &localFile, const KData &remoteFile);
	bool openPort( KTcpClientSocket& sock );
	bool modDate( const KData& path, KData& date );
	bool dir();
	void close();
	bool isConnected();
	void setCallbackFunc( FTP_TRANS_CALLBACK func, void* param );
	void setNotifyPercent( unsigned int percent );
	FtpFileItem* getFtpItem( const KData& name );

public:
	list< FtpFileItem > _fileList;

private:
	KTcpClientSocket _clientSock;
	KConnection _conn;
	char _cmdBuff[ 1024 ];
	long _timeout;
	bool _bConnected;
	unsigned int m_pace;
	FTP_TRANS_CALLBACK m_callBack;
	void *m_param;
};

#endif
