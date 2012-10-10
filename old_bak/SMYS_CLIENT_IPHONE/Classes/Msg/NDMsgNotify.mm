/*
 *  NDMsgNotify.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgNotify.h"
#include "NDMsgDefine.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"

void NDMsgNotify::Process(NDTransData* data, int len)
{
	//BytesArrayInput input = new BytesArrayInput(data);
	int action = data->ReadShort();
	int code = data->ReadShort();
	int count = data->ReadShort();
	
	
	/*
	String str = null;
	for (int i = 0; i < count; i++) {
		if (str == null) {
			str = input.readString();
		} else {
			str += input.readString();
		}
	}
	*/
	
	if (action == NDServerCode::LOGIN) {
		switch (code) {
			case 0: // <帐号>服务器认证失败
				NDLog(@"认证失败");//, str == null ? "无返回信息,认证失败" : str);
				//workThread = null;
				//state = 0;
				break;
			case 1: // 登录<游戏>服务器成功
				NDLog(@"登录游戏成功");
				break;
			case 2: // 登录<游戏>服务器失败
			case 3: // 连接<帐号>服务器失败
			case 4: // 连接<游戏>服务器失败
				NDLog(@"连接服务器失败");//, str == null ? "无返回信息,连接失败" : str);
				//workThread = null;
				//state = 0;
				break;
			case 5: // 登录<帐号>服务器超时
			case 6: // 登录<游戏>服务器超时
				NDLog(@"连接失败", "服务器超时");
				//workThread = null;
				//state = 0;
				break;
			case 7: // <代理服务器>繁忙
				NDLog(@"连接失败", "服务器已达到人数上限!");
				//workThread = null;
				//state = 0;
				break;
			case 8: // <代理服务器>已达到人数上限
				NDLog(@"连接失败", "服务器已达到人数上限!");
				//workThread = null;
				//state = 0;
				break;
			case 9: // 登录<游戏>服务器成功 无角色
				//GameManager.getInstance().getCurrentScreen().setNextScreen(GameManager.SCREEN_CREATEROLE);
				break;
			case 10: // 继续登录需要等待,由玩家选择
				//GameManager.getInstance().getCurrentScreen().showLoginWaitDlg(str);
				break;
			default: // 登录<游戏>服务器失败
				NDLog(@"连接失败");//, str);
				//workThread = null;
				//state = 0;
				break;
		}
	}
}