/*
 *  NewVipStoreScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-4.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_VIP_STORE_SCENE_H_
#define _NEW_VIP_STORE_SCENE_H_

#include "NDCommonScene.h"
#include "NewVipStore.h"
//#include "NewRecharge.h"

using namespace NDEngine;

enum  
{
	eNewVipStoreBegin = 0,
	eNewVipStoreShop = eNewVipStoreBegin,
	eNewVipStoreRecharge,
	eNewVipStoreEnd,
};

/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* this class
*/
// class NewVipStoreScene :
// public NDCommonSocialScene,
// public HFuncTabDelegate
// {
// 	DECLARE_CLASS(NewVipStoreScene)
// 	
// 	NewVipStoreScene();
// 	
// 	~NewVipStoreScene();
// 	
// public:
// 	
// 	static NewVipStoreScene* Scene();
// 	
// 	static void UpdateShop();
// 	
// 	void Initialization(); override
// 	
// 	void OnButtonClick(NDUIButton* button); override
// 	
// 	void OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex);
// 	
// 	void ShowRechare();
// 	
// private:
// 	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
// 	
// 	void InitShop(NDUIClientLayer* client);
// 	
// 	void InitRecharge(NDUIClientLayer* client);
// 	
// private:
// 	VipShop* m_shop;
// 	Recharge* m_recharge;
// 	static NewVipStoreScene* s_NewVipStoreScene;
// };


#endif // _NEW_VIP_STORE_SCENE_H_