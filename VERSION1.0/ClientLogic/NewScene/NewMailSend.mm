/*
 *  NewMailSend.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-27.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewMailSend.h"
#include "NDUtility.h"
#include "NewMail.h"

enum 
{
	eSocialBegin = 0,
	eSocialMail = eSocialBegin,
	eSocialEnd,
};

IMPLEMENT_CLASS(NewMailSendScene, NDCommonSocialScene)

NewMailSendScene::NewMailSendScene()
{
}

NewMailSendScene::~NewMailSendScene()
{
}

NewMailSendScene* NewMailSendScene::Scene(const char* recvName/*=NULL*/)
{
	NewMailSendScene *scene = new NewMailSendScene;
	
	scene->Initialization(recvName);
	
	return scene;
}

void NewMailSendScene::Initialization(const char* recvName/*=NULL*/)
{
	NDCommonSocialScene::Initialization();
	
	InitTab(eSocialEnd);
	
	for(int j = eSocialBegin; j < eSocialEnd; j++)
	{
		TabNode* tabnode = GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = 18*(11+j);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	SetClientLayerBackground(eSocialMail, true);
	InitSendMail(GetClientLayer(eSocialMail), recvName);
}

void NewMailSendScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void NewMailSendScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonSocialScene::OnTabLayerSelect(tab, lastIndex, curIndex);
}

void NewMailSendScene::InitSendMail(NDUIClientLayer* client, const char* recvName/*=NULL*/)
{
	if (!client) return;
	
	NewMailSendUILayer* mail = new NewMailSendUILayer;
	
	mail->Initialization(recvName);
	
	mail->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	client->AddChild(mail);
}

