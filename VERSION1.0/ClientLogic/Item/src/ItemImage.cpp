/*
 *  ItemImage.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-21.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ItemImage.h"
#include "define.h"
#include "NDUtility.h"
#include "Item.h"
#include "ItemMgr.h"
#include "ScriptGameLogic.h"
#include "NDPath.h"

#define ITEM_SIZE_W	(80)
#define ITEM_SIZE_H (80)

#define SMALL_ITEM_SIZE_W (23)
#define SMALL_ITEM_SIZE_H (23)

#define SKILL_SIZE_W (34)
#define SKILL_SIZE_H (34)

ItemImage::ItemImage()
{
}

ItemImage::~ItemImage()
{
}

NDPicture*  ItemImage::GetItemPicByType(int iItemType, bool gray,
										bool smallicon/*=false*/)
{
	int iIconIndex = -1;
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		iIconIndex = itemtype->m_data.m_iconIndex;
	}
	
	if (iIconIndex > 0)
	{
		iIconIndex = (iIconIndex % 100 - 1) + (iIconIndex / 100 - 1) * 6;
		return ItemImage::GetItem(iIconIndex, gray, smallicon);
	}
	return NULL;
}

NDPicture* ItemImage::GetItem(int iIndex, bool gray/*=false*/, bool smallicon/*=false*/)
{
	if (iIndex < 0)
	{
		return NULL;
	}
	
	int iItemSizeW = smallicon ? SMALL_ITEM_SIZE_W : ITEM_SIZE_W;
	int iItemSizeH = smallicon ? SMALL_ITEM_SIZE_H : ITEM_SIZE_H;
	
	int iX = iIndex % 6 * iItemSizeW;
	int iY = iIndex / 6* iItemSizeH;
	
	NDPicture* pkResource = NDPicturePool::DefaultPool()->AddPicture(
		(smallicon ? NDPath::GetImgPathBattleUI("item_small.png") :
		NDPath::GetSMImgPath("portrait/Goods.png") ) , true);

	if (!pkResource)
	{
		return NULL;
	}

	CCSize kSize = pkResource->GetSize();

	if ( iX + iItemSizeW > kSize.width || iY + iItemSizeH > kSize.height ) 
	{
		delete pkResource;
		return NULL;
	}
	
	pkResource->Cut(CCRectMake(iX, iY, iItemSizeW, iItemSizeH));
	
	return pkResource;
}

NDPicture* ItemImage::GetPinZhiPic(int iItemType, bool smallicon/*=false*/)
{
	NDPicture* pkResource = NULL;
	
	int iItemSizeW = smallicon ? SMALL_ITEM_SIZE_W : ITEM_SIZE_W;
	int iItemSizeH = smallicon ? SMALL_ITEM_SIZE_H : ITEM_SIZE_H;
	
	std::vector<int> kIDs = Item::getItemType(iItemType);
	int x = ITEM_SIZE_H, y =14 * iItemSizeH;
	//int result = -1;
	if ( kIDs[0] > 1 ) 
	{
		return pkResource;
	}
	if (kIDs[7] == 5) 
	{
	} 
	else if (kIDs[7] == 6)
	{
		x += iItemSizeH;
	} 
	else if (kIDs[7] == 7)
	{
		x += iItemSizeH * 2;
	} 
	else if (kIDs[7] == 8)
	{
		x += iItemSizeH * 3;
	}
	else if (kIDs[7] == 9)
	{
		x += iItemSizeH * 4;
	}
	else
	{
		return pkResource;
	}
	
	pkResource = NDPicturePool::DefaultPool()->AddPicture(
		NDPath::GetImgPathBattleUI(smallicon ? "item_small.png" : "items.png"), true);
	if (!pkResource)
	{
		return NULL;
	}
	
	CCSize size = pkResource->GetSize();
	if ( x + iItemSizeW > size.width || y + iItemSizeH > size.height ) 
	{
		delete pkResource;
		return NULL;
	}
	
	pkResource->Cut(CCRectMake(x, y, iItemSizeW, iItemSizeH));
	
	return pkResource;

}

NDPicture* ItemImage::GetItemByIconIndex(int iIconIndex, bool gray/*=false*/,
										 bool smallicon/*=false*/)
{
	if (iIconIndex > 0)
	{
		iIconIndex = (iIconIndex % 100 - 1) + (iIconIndex / 100 - 1) * 6;
	}
	
	if (iIconIndex != -1)
	{
		return GetItem(iIconIndex, gray, smallicon);
	}
	
	return NULL;
}



NDPicture* GetSkillIconByIconIndex(int iIconIndex, bool gray/*=false*/)
{
	int nStartX = (iIconIndex % 100 - 1) * SKILL_SIZE_W;
	int nStartY = (iIconIndex / 100 - 1) * SKILL_SIZE_H;
	
	NDPicture *res = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("skillicon.png"), gray);
	
	if (res) {
		CCSize size = res->GetSize();
		if (nStartX < 0 || nStartY < 0 || nStartX + SKILL_SIZE_W > size.width || nStartY + SKILL_SIZE_H > size.height )
		{
			SAFE_DELETE(res);
			return NULL;
		}
		res->Cut(CCRectMake(nStartX, nStartY, SKILL_SIZE_W, SKILL_SIZE_H));
		return res;
	}
	return NULL;
}

NDPicture* ItemImage::GetSMItem(int nIconVal)
{
    /*
	NDPicture *res = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("portrait/Goods.png"), true);
	if (!res)
	{
		return NULL;
	}
	
	CCSize kSize = pkResource->GetSize();
    
	CGSize size = res->GetSize();
	int nCol	= nIconVal % 100 - 1;
	int nRow	= nIconVal / 100 - 1;
	if (nRow < 0 || nCol < 0 ||
		ITEM_SIZE_W * nCol > size.width || ITEM_SIZE_H * nRow > size.height)
	{
		delete res;
		return NULL;
	}
	res->Cut(CGRectMake(ITEM_SIZE_W * nCol, ITEM_SIZE_H * nRow, ITEM_SIZE_W, ITEM_SIZE_H));
	return res;
    */
    int nCol = nIconVal % 10 - 1;
    int nRow = nIconVal / 10 % 10 - 1;
    int bw = nIconVal / 100;
    char keyString[255];
    sprintf(keyString, "portrait/Goods%d.png",bw);
    NDPicture *res = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath(keyString), true);
    if (!res)
	{
		return NULL;
	}
    
    CCSize size = res->GetSize();
    if (nRow < 0 || nCol < 0 ||
		ITEM_SIZE_W * nCol > size.width || ITEM_SIZE_H * nRow > size.height)
	{
		delete res;
		return NULL;
	}
	
	res->Cut(CCRectMake(ITEM_SIZE_W * nCol, ITEM_SIZE_H * nRow, ITEM_SIZE_W, ITEM_SIZE_H));
	return res;
}

NDPicture* ItemImage::GetSMItemNew(int nIconVal)
{
	if (10000 <= nIconVal || 0 > nIconVal)
	{
		return NULL;
	}
	
	std::string str;
	
	if (nIconVal < 10)
	{
		str		= "000";
	}
	else if (nIconVal < 100)
	{
		str		= "00";
	}
	else if (nIconVal < 1000)
	{
		str		= "0";
	}
	
	std::stringstream strVal;
	strVal << "portrait/goods" << str << nIconVal << ".png";
	
	return	NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath(strVal.str().c_str()), true);
}