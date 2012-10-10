/*
 *  Auction_Item.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __AUCTION_ITEM_H__
#define __AUCTION_ITEM_H__

#include "define.h"
#include "Item.h"

class Auction_Item : public Item {
public:
	Auction_Item(int idItemType);
	
	string getAuctionItemStr(bool bolIncludeName, bool bolEnt, bool showColor);
	string getAuctionItemStr(const string& des, bool bolIncludeName, bool bolEnt);
	
	/** 出价者ID */
	int itemBidderID;
	/** 上架时间 */
	int time;
	/** 最低价 */
	int minPrice;
	/** 一口价 */
	int maxPrice;
	/** 出价者名字 */
	string bidderName;
	/** 0元宝 1银两 */
	int payType;
	
	/** 序列，1-10   */
	int seq;
};

#endif