/*
 *  PetInfoScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PetInfoScene.h"
#include "NDDirector.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "GameUIAttrib.h"
#include "NewPlayerTask.h"
#include "FarmInfoScene.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"
#include "NewGameUIPetAttrib.h"
#include "PetSkillInfo.h"
#include "NDMapMgr.h"
#include "CPet.h"
#include "NewPetScene.h"
/*
enum 
{
	ePetInfoBegin = 0,
	ePetInfoAttr = ePetInfoBegin,
	ePetInfoSkill,
	ePetInfoEnd,
};

IMPLEMENT_CLASS(PetInfoScene, NDCommonScene)

PetInfoScene* PetInfoScene::Scene(bool onlyAttr/*=false*//*)
{
	PetInfoScene *scene = new PetInfoScene;
	
	scene->Initialization(onlyAttr);
	
	return scene;
}

PetInfoScene::PetInfoScene()
{
}

PetInfoScene::~PetInfoScene()
{
}

void PetInfoScene::Initialization(bool onlyAttr/*=false*//*)
{
	NDCommonScene::Initialization();
	
	const char * tabtext[ePetInfoEnd] = 
	{
		NDCommonCString("property"), NDCommonCString("skill"),
	};
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	for (int i = ePetInfoBegin; i < ePetInfoEnd; i++) 
	{
		if (onlyAttr && i == ePetInfoSkill) continue;
		
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 70, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 70, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = ePetInfoBegin; i < ePetInfoEnd; i++) 
	{	
		if (onlyAttr && i == ePetInfoSkill) continue;
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == ePetInfoAttr) 
		{
			InitAttr(client, onlyAttr);
		}
		else if (i == ePetInfoSkill)
		{
			InitSkill(client);
		}
	}
	
	this->SetTabFocusOnIndex(ePetInfoAttr, true);
}

void PetInfoScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void PetInfoScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonScene::OnTabLayerSelect(tab, lastIndex, curIndex);
}

void PetInfoScene::InitAttr(NDUIClientLayer* client, bool onlyAttr/*=false*//*)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tab = new NDFuncTab;
	tab->Initialization(2, CGPointMake(200, 5));
	
	for(int j =0; j<2; j++)
	{
		TabNode* tabnode = tab->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = (j == 0 ? 18*4 : 18*5);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	

	NewGameUIPetAttrib *attr = new NewGameUIPetAttrib;
	attr->Initialization(!onlyAttr);
	attr->SetFrameRect(CGRectMake(0, 0, 200, sizeClient.height));
	client->AddChild(attr);
	
	attr->AddPropAlloc(tab->GetClientLayer(0));
	attr->AddProp(tab->GetClientLayer(1));
	
	client->AddChild(tab);
	
}

void PetInfoScene::InitSkill(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	
	PetSkillTab *skill = new PetSkillTab;
	skill->Initialization();
	skill->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
	client->AddChild(skill);
}*/

enum 
{
	eBegin = 0,
	ePetInfo = eBegin,
	eEnd,
};

IMPLEMENT_CLASS(NewPetInfoScene, NDCommonScene)

NewPetInfoScene::NewPetInfoScene()
{
	m_tabNodeSize.width = 150;
}

NewPetInfoScene::~NewPetInfoScene()
{

}

NewPetInfoScene* NewPetInfoScene::Scene(OBJID idPet)
{
	NewPetInfoScene *scene = new NewPetInfoScene;
	
	scene->Initialization(idPet);
	
	return scene;
}

void NewPetInfoScene::Initialization(OBJID idPet)
{
	NDCommonScene::Initialization();
	
	PetInfo* petInfo = PetMgrObj.GetPet(idPet);
	
	bool showPet = petInfo != NULL;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	for (int i = eBegin; i < eEnd; i++) 
	{
		if (!showPet) continue;
		
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 150, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 150, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(petInfo ? petInfo->str_PET_ATTR_NAME.c_str() : "");
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = eBegin; i < eEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == ePetInfo)
		{
			if (showPet)
				InitPet(client, idPet);
		}
	}
	
	this->SetTabFocusOnIndex(ePetInfo, true);
}

void NewPetInfoScene::OnButtonClick(NDUIButton* button)
{
	OnBaseButtonClick(button);
}

void NewPetInfoScene::InitPet(NDUIClientLayer* client, OBJID idPet)
{
	CGSize clientSize = client->GetFrameRect().size;
	
	CUIPet *pUiPet = new CUIPet;
	if (!pUiPet) {
		return;
	}
	
	if (!pUiPet->Init(0, idPet, false)) {
		SAFE_DELETE(pUiPet);
		return;
	}
	
	pUiPet->SetFrameRect(CGRectMake(0, 0, clientSize.width, clientSize.height));
	
	client->AddChild(pUiPet);
}
