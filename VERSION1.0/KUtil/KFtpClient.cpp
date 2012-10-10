#include "KFtpClient.h"
#include "KFile.h"


#define CRLF "\r\n"
#define MTU 1500

KFtpClient::KFtpClient(void)
{
	_timeout = 5000;
	_bConnected = false;
	m_pace = 10;
	m_callBack = NULL;
}

KFtpClient::~KFtpClient(void)
{
}


void
KFtpClient::setTimeout( long millsec )
{
	_timeout = millsec;
}


bool
KFtpClient::connect( const KData& server, short port )
{
	close();
	_clientSock.setServer( server, port );
	if ( !_clientSock.connect() )
		return false;
	_conn = _clientSock.getConn();
	if ( _conn.readLine(_cmdBuff,1024,_timeout)<=0 || _cmdBuff[0]!='2' )
	{
		return false;
	}
	else
	{
		return true;
	}
}


bool KFtpClient::ftpCmd( const KData& cmd, char ch )
{
	if ( _conn.writeData(cmd,_timeout)!=(int)cmd.length() )
		return false;
	if ( _conn.readLine(_cmdBuff,1024,_timeout)<=0 )
		return false;
	if ( _cmdBuff[0] != ch )
	{
		return false;
	}
	return true;
}

bool
KFtpClient::login( const KData& user, const KData& pasw )
{
	KData dtCmd = "USER ";
	dtCmd += user;
	dtCmd += CRLF;

	if ( !ftpCmd(dtCmd,'2') )
	{
		if ( _cmdBuff[0] != '3' )
		{
			return false;
		}
	}

	dtCmd = "PASS ";
	dtCmd += pasw;
	dtCmd += CRLF;
	if ( !ftpCmd(dtCmd,'2') )
	{
		return false;
	}
	_bConnected = true;
	return true;
}

bool
KFtpClient::chdir( const KData& dir )
{
	if ( dir.length()>250 )
	{
		return false;
	}
	KData dtCmd = "CWD ";
	dtCmd += dir;
	dtCmd += CRLF;
	if ( !ftpCmd(dtCmd,'2') )
	{
		return false;
	}
	return true;
}

bool
KFtpClient::mkdir( const KData& dir )
{
	if ( dir.length() > 250 )
	{
		return false;
	}
	KData dtCmd = "MKD ";
	dtCmd += dir;
	dtCmd += CRLF;
	if ( !ftpCmd(dtCmd,'2') )
	{
		return false;
	}
	return true;
}


bool KFtpClient::dir()
{
	_fileList.clear();
	if ( !ftpCmd("TYPE A\r\n",'2') )
	{
		return false;
	}
	KTcpClientSocket clientSock;
	if ( !openPort(clientSock) )
		return false;
	if ( !ftpCmd("LIST\r\n",'1') )
	{
		return false;
	}
	KConnection conn = clientSock.getConn();
	int iRet;
	while ( (iRet=conn.readLine(_cmdBuff,1024,_timeout))>=0 )
	{
		map<int,KData> mapKData = KData(_cmdBuff).split( " ", true );
		FtpFileItem item;
		if ( mapKData[0].length() == 8 )
		{
			item.name = mapKData[3];
			item.bDir = (mapKData[2]=="<DIR>");
			if ( !item.bDir )
				item.fileLen = (int)mapKData[2];
			else
				item.fileLen = 0;
		}
		else
		{
			FtpFileItem item;
			item.name = mapKData[8];
			item.bDir = (mapKData[0][(unsigned int)0]=='d');
			item.fileLen = (int)mapKData[4];
		}
		_fileList.push_back( item );
	}
	if ( _conn.readLine(_cmdBuff,1024,_timeout)<=0 || _cmdBuff[0]!='2' )
	{
		return false;
	}
	return true;
}


FtpFileItem* KFtpClient::getFtpItem( const KData& name )
{
	for ( list< FtpFileItem >::iterator iter=_fileList.begin(); iter!=_fileList.end(); iter++ )
	{
		if ( iter->name == name )
		{
			return &(*iter);
		}
	}
	return NULL;
}


bool KFtpClient::modDate( const KData& path, KData& date )
{
	KData dtCmd = "MDTM ";
	dtCmd += path;
	dtCmd += CRLF;
	if ( !ftpCmd(dtCmd,'2') )
	{
		return false;
	}
	else
	{
		date = (char*)(_cmdBuff+4);
	}
	return true;
}


bool KFtpClient::openPort( KTcpClientSocket& sock )
{
	if ( !ftpCmd("PASV\r\n",'2') )
	{
		return false;
	}

	struct sockaddr sa;
	memset( &sa, 0, sizeof(sa) );
	sa.sa_family = AF_INET;

	char* cp = NULL;
	cp = strchr( _cmdBuff, '(' );
	if ( cp == NULL )
	{
	    return false;
	}
	cp++;
	unsigned int v[6];
	sscanf( cp,"%u,%u,%u,%u,%u,%u",&v[2],&v[3],&v[4],&v[5],&v[0],&v[1] );
	sa.sa_data[2] = v[2];
	sa.sa_data[3] = v[3];
	sa.sa_data[4] = v[4];
	sa.sa_data[5] = v[5];
	sa.sa_data[0] = v[0];
	sa.sa_data[1] = v[1];

	sock.setServer( sa );
	if ( !sock.connect() )
		return false;
	return true;
}


bool KFtpClient::getFile( const KData& localFile, const KData& remoteFile )
{
	if ( !ftpCmd("TYPE I\r\n",'2') )
	{
		return false;
	}
	
	KTcpClientSocket clientSock;
	if ( !openPort(clientSock) )
		return false;

	KData dtCmd = "RETR ";
	dtCmd += remoteFile;
	dtCmd += CRLF;
	
	if ( !ftpCmd(dtCmd,'1') )
		return false;

	KConnection conn = clientSock.getConn();
	unsigned char buff[MTU];
	KFile file;
	if ( !file.setFile(localFile,KFile::KFILE_READWRITE) )
		return false;

	int iReaded;
	int iRet;
	while ( (iRet=conn.readData(buff,MTU,iReaded,_timeout)) > 0 )
	{
		if ( file.write(buff,iReaded) != iReaded )
		{
			return false;
		}
	}
	if ( file.write(buff,iReaded) != iReaded )
	{
		return false;
	}
	if ( _conn.readLine(_cmdBuff,1024,_timeout)<=0 || _cmdBuff[0]!='2' )
	{
		return false;
	}
	return true;
}

void KFtpClient::setNotifyPercent( unsigned int percent )
{
	if ( percent > 100 )
		return;
	m_pace = percent;
}


bool KFtpClient::putFile(const KData &localFile, const KData &remoteFile)
{
	if ( !ftpCmd("TYPE I\r\n",'2') )
	{
		return false;
	}
	KTcpClientSocket clientSock;
	if ( !openPort( clientSock ) )
		return false;

	KData dtCmd = "STOR ";
	dtCmd += remoteFile;
	dtCmd += CRLF;
	
	if ( !ftpCmd(dtCmd,'1') )
	{
		return false;
	}

	KConnection conn = clientSock.getConn();
	conn.setTimeout( _timeout );
	unsigned char buff[MTU];
	KFile file;
	if ( !file.setFile(localFile,KFile::KFILE_READ) )
		return false;

	int fileLen = file.getFileLen();
	int iRead;
	int iReaded = 0;
	int gap = fileLen / m_pace;
	int iNotifyPos = gap;
	int pos = 1;
	while ( (iRead=file.read(buff,MTU)) > 0  )
	{
		if ( conn.writeData(buff,iRead) != iRead )
		{
			return false;
		}
		if ( m_callBack != NULL )
		{
			iReaded += iRead;
			if ( iReaded > iNotifyPos )
			{
				iNotifyPos = gap * ++pos;
				m_callBack( (int)((float)iReaded/(float)fileLen*100), m_param );
			}
		}
	}
	if ( m_callBack != NULL )
		m_callBack( 100, m_param );
	conn.close();
	clientSock.close();
	if ( _conn.readLine(_cmdBuff,1024,_timeout)<=0 || _cmdBuff[0]!='2' )
	{
		return false;
	}
	return true;
}

void KFtpClient::close()
{
	_conn.close();
	_clientSock.close();
	_bConnected = false;
}

bool KFtpClient::isConnected()
{
	return _bConnected;
}

void KFtpClient::setCallbackFunc( FTP_TRANS_CALLBACK func, void* param )
{
	m_callBack = func;
	m_param = param;
}
