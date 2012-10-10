/*
 *  AuctionSearchLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __AUCTION_SEARCH_LAYER_H__
#define __AUCTION_SEARCH_LAYER_H__

#include "define.h"
#include "NDUILayer.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"

using namespace NDEngine;

class AuctionSearchLayer :
public NDUILayer,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(AuctionSearchLayer)
	AuctionSearchLayer();
	~AuctionSearchLayer();
	
public:
	static void Show();

public:
	bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void Initialization();
	void OnCustomViewCancle(NDUICustomView* customView); override
private:
	static AuctionSearchLayer* s_instance;
	
private:
	NDUITableLayer* m_tlMain;
	Byte m_selType;
	Byte m_selLevel;
	Byte m_selQuality;
	Byte m_selAppend;
	Byte m_selMoney;
	
private:
	void ShowFilter(int filterType);
};

#endif