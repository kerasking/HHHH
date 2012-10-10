/*
 *  NDMsgChooseServer.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgChooseServer.h"

#include "NDMsgNotify.h"
#include "NDMsgDefine.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include <vector>
#include <string>

void NDMsgChooseServer::Process(NDTransData* data, int len)
{
	
	int size = 0; (*data) >> size;
	int available = 0;
	std::vector<std::string> apnArray;
	std::vector<std::string> subContent;
	std::vector<std::string> serverNames;;
	//btStates = new byte[size][];
	std::vector<std::string> ips;;
	std::vector<int>ports;
	ports.reserve(size);
	//String[] contentArray = null;
	std::vector<std::string> nameArray;
	std::string sb;
	for (int i = 0; i < size; i++) {
		std::string tmp; tmp.clear();
		//apnArray[i] = in.readString();//大区名(String)
		tmp = data->ReadUnicodeString();
		NSLog(@"%s", tmp.c_str());
		apnArray.push_back(tmp); tmp.clear();
		//ips[i] = in.readString();
		tmp = data->ReadUnicodeString(); ips.push_back(tmp); tmp.clear();
		//ports[i] = in.readInt();
		(*data) >> ports[i];
		//available = in.readInt();//可用服务器个数(int)
		(*data) >> available;
		
		//contentArray = new String[available];
		//nameArray = new String[available];
		//subContent[i] = contentArray;
		//serverNames[i] = nameArray;
		//btStates[i] = new byte[available];
		//byte state = 0;
		std::string serverName;
		for (int j = 0; j < available; j++) {
			//serverName = in.readString();//具体服务器名(String)
			serverName = data->ReadUnicodeString(); 
			NSString *test = [NSString stringWithFormat:@"%S", serverName.c_str()];
			NSLog(@"%@", test);
			sb.append(serverName);serverName.clear();
			/*
			int len = T.stringWidth(serverName);
			
			if (len < serverNameLen) {
				int nCnt = (serverNameLen - len) / spaceWidth;
				for (int n = 0; n < nCnt; n++) {
					sb.append(' ');
				}
			}
			 */
			
			/*
			contentArray[j] = sb.toString();
			sb.delete(0, sb.length());
			*/
			
			//nameArray[j] = in.readString();//具体服务器名(String)
			tmp = data->ReadUnicodeString(); nameArray.push_back(tmp); tmp.clear();
			/*
			btStates[i][j] = (byte)in.read();
			if (btStates[i][j] >= STATE_NAMES.length) {
				btStates[i][j] = (byte) (STATE_NAMES.length - 1);
			}
			if (btStates[i][j] < 0) {
				btStates[i][j] = 0;
			}
			 */
		}
		//flag = true;
	}
}

void NDMsgChooseServer::SendGetServerInfoRequest()
{
	NDTransData data;
	data << (unsigned short)NDServerCode::ACQUIRE_SERVER_INFO_REQUEST << (unsigned short)NDServerCode::ACQUIRE_SERVER_INFO_REQUEST;
	
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
}