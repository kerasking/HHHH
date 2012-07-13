/*
 *  NewMailSend.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-27.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_MAIL_SEND_H_
#define _NEW_MAIL_SEND_H_

#include "NDCommonScene.h"

using namespace NDEngine;

class NewMailSendScene :
public NDCommonSocialScene
{
	DECLARE_CLASS(NewMailSendScene)
	
	NewMailSendScene();
	
	~NewMailSendScene();
	
public:
	
	static NewMailSendScene* Scene(const char* recvName=NULL);
	
	void Initialization(const char* recvName=NULL); override
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void InitSendMail(NDUIClientLayer* client, const char* recvName=NULL);
};


#endif // _NEW_MAIL_SEND_H_