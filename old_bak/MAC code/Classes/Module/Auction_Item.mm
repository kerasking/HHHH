/*
 *  Auction_Item.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Auction_Item.h"
#include "NDUtility.h"
#include <sstream>
using namespace std;

Auction_Item::Auction_Item(int idItemType) : Item(idItemType)
{
	
}

string Auction_Item::getAuctionItemStr(bool bolIncludeName, bool bolEnt, bool showColor)
{
	string separate = bolEnt ? "\n" : " ";
	stringstream desx;
	
	if (bolIncludeName) {
		desx << (getItemNameWithAdd()) << separate;
	}
	
	if (this->iAmount > 0) {
		int type = getIdRule(this->iItemType, ITEM_TYPE); // 物品类型
		if (type == 0) {
			// dwAmount = "耐久:" + item.dwAmount + "\n";
		} else if (isRidePet()) {
			desx << NDCommonCString("TiLi") << ":" << iAmount << separate;
		} else {
			desx << NDCommonCString("amount") << ":" << iAmount << separate;
		}
	}
	
	desx << NDCString("NewPaiPrice") << minPrice;
	
	if (payType == 0) {
		desx << (NDCommonCString("emoney"));
	} else {
		desx << (NDCommonCString("money"));
	}
	if (maxPrice != 0) {
		desx << "," << NDCommonCString("YiKouPrice") << maxPrice;
	}
	if (itemBidderID != iOwnerID) {
		desx << NDCString("ChuPaiPrice")  << this->bidderName;
	}
	
	desx << separate << NDCommonCString("deadline") << ":";
	desx << getStringTime(this->time + 172800);
	
	if (this->getStonesCount() > 0) {
		desx << separate << NDCommonCString("BaoShi") << this->getStonesCount() << NDCommonCString("ge") << separate;
	}
	
	desx << separate << makeItemDes(false, showColor);
	return desx.str();
}

string Auction_Item::getAuctionItemStr(const string& des, bool bolIncludeName, bool bolEnt)
{
	string separate = bolEnt ? "\n" : " ";
	stringstream desx;
	if (bolIncludeName) {
		desx << (this->getItemNameWithAdd()) << separate;
	}
	desx << (NDCString("NewPaiPrice")) << this->minPrice;
	
	if (payType == 0) {
		desx << (NDCommonCString("emoney"));
	} else {
		desx << (NDCommonCString("money"));
	}
	if (maxPrice != 0) {
		desx << "," << NDCommonCString("YiKouPrice") << maxPrice;
	}
	if (itemBidderID != this->iOwnerID) {
		desx <<  NDCString("NewPaiPrice") << bidderName;
	}
	desx << separate << NDCommonCString("deadline") << ":";
	desx << (getStringTime(this->time + 172800));
	if (this->getStonesCount() > 0) {
		desx << separate << NDCommonCString("BaoShi") << this->getStonesCount() << NDCommonCString("ge") << separate;
	}
	
	desx << separate << des;
	
	return desx.str();
}