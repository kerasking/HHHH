/*
 *  ItemImage.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-21.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _ITEM_IMAGE_H_
#define _ITEM_IMAGE_H_

#include "NDPicture.h"

using namespace NDEngine;

class ItemImage
{
public:
	static NDPicture* GetItem(int iIndex, bool gray=false, bool smallicon=false);
	
	static NDPicture* GetItemPicByType(int iItemType, bool gray=false, bool smallicon=false);
	
	static NDPicture* GetPinZhiPic(int iItemType, bool smallicon=false);
	
	static NDPicture* GetItemByIconIndex(int iIconIndex, bool gray=false, bool smallicon=false);
	
	static NDPicture* GetSMItem(int nIconVal);
protected:
	ItemImage();
	~ItemImage();
};

NDPicture* GetSkillIconByIconIndex(int iIconIndex, bool gray=false);

#endif // _ITEM_IMAGE_H_