/* *  NewVipStoreScene.mm *  DragonDrive * *  Created by jhzheng on 11-11-4. *  Copyright 2011 __MyCompanyName__. All rights reserved. * */#include "NewVipStoreScene.h"#include "NDUtility.h"#include "BattleFieldData.h"#include "NDMapMgr.h"#include "NDPath.h"IMPLEMENT_CLASS(NewVipStoreScene, NDCommonSocialScene)NewVipStoreScene* NewVipStoreScene::s_NewVipStoreScene = NULL;NewVipStoreScene::NewVipStoreScene(){	m_shop = NULL;		m_recharge = NULL;		s_NewVipStoreScene = this;}NewVipStoreScene::~NewVipStoreScene(){	s_NewVipStoreScene = NULL;}NewVipStoreScene* NewVipStoreScene::Scene(){	NewVipStoreScene *scene = new NewVipStoreScene;		scene->Initialization();		return scene;}void NewVipStoreScene::Initialization(){	NDCommonSocialScene::Initialization();		InitTab(eNewVipStoreEnd);		for(int j = eNewVipStoreBegin; j < eNewVipStoreEnd; j++)	{		TabNode* tabnode = GetTabNode(j);				NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));				int index = 0;		if (j == eNewVipStoreShop)			index = 19;		else if (j == eNewVipStoreRecharge)			index = 21;		int startX = 18*(index+j);				pic->Cut(CGRectMake(startX, 36, 18, 36));		picFocus->Cut(CGRectMake(startX, 0, 18, 36));				tabnode->SetTextPicture(pic, picFocus);	}		SetClientLayerBackground(eNewVipStoreShop, true);	InitShop(GetClientLayer(eNewVipStoreShop));		SetClientLayerBackground(eNewVipStoreRecharge);			this->SetTabFocusOnIndex(eNewVipStoreShop);}void NewVipStoreScene::OnButtonClick(NDUIButton* button){	if (OnBaseButtonClick(button)) return;}void NewVipStoreScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex){	NDCommonSocialScene::OnTabLayerSelect(tab, lastIndex, curIndex);		if (curIndex != eNewVipStoreRecharge) return;		if (m_recharge == NULL)	{		sendChargeInfo(0);		NDTransData bao(_MSG_CHARGE_GIFT_INFO);		SEND_DATA(bao);	}}void NewVipStoreScene::OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex){	}void NewVipStoreScene::InitShop(NDUIClientLayer* client){		if (!client) return;		m_shop = new VipShop;		m_shop->Initialization();		client->AddChild(m_shop); }void NewVipStoreScene::InitRecharge(NDUIClientLayer* client){	if (!client) return;		m_recharge = new Recharge;		m_recharge->Initialization();		client->AddChild(m_recharge); }void NewVipStoreScene::UpdateShop(){	if (!s_NewVipStoreScene) return;		if (s_NewVipStoreScene->m_shop) s_NewVipStoreScene->m_shop->UpdateShopInfo();}void NewVipStoreScene::ShowRechare(){	InitRecharge(GetClientLayer(eNewVipStoreRecharge));		this->SetTabFocusOnIndex(eNewVipStoreRecharge);}