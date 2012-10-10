/*
 *  FormulaMaterialData.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FormulaMaterialData.h"
#include "Item.h"
#include "NDUtility.h"
#include <vector>
#include <sstream>

FormulaMaterialData::FormulaMaterialData(int iid, int grade,int matID_1,int count1,int matID_2,int count2,int matID_3,int count3,int prodItem ,int money,int emoney,std::string sName,int iconIdx) 
{
	idFormula = iid;
	formulaName = sName;
	init(grade, matID_1, count1, matID_2, count2, matID_3, count3, prodItem,money,emoney,iconIdx);
}

void FormulaMaterialData::init(int grades,int matID_1,int count1,int matID_2,int count2,int matID_3,int count3,int prodItem,int money,int emoney,int iconIdx)
{
	grade = grades;
	itemType1 = matID_1;
	itemCount1 = count1;
	itemType2 = matID_2;
	itemCount2 = count2;
	itemType3 = matID_3;
	itemCount3 = count3;
	productItemType = prodItem;
	need_Money = money;
	need_EMoney = emoney;
	iconIndex = iconIdx;
}

int FormulaMaterialData::getSkillID()
{
	return (idFormula/10000)%100;
}

bool FormulaMaterialData::isFormula(int formulaId) 
{
	std::vector<int> arr = Item::getItemType(formulaId);
	int item_type = arr[0]; // 千万
	int item_equip = arr[1]; // 百万
	int item_class = arr[2]; // 十万
	if (item_type != 2 || (item_equip * 10 + item_class) != 51) { //2表消耗品,51
		return false;
	}
	return true;
}

//	public void readName() {
//		formulaName = new Item(idFormula).getItemName();
//	}

//	public void readAlchemyDetailById() {
//		InputStream is = T.getResourceAsStream("/formulatype.ini");
//		DataInputStream din = new DataInputStream(is);
//		int length = T.currentFileInputStreamSize;
//		int index = 0;
//		while (index < length) {
//			try {
//				int id = din.readInt();
//				index += 4;
//				long n = din.readLong();
//				index += 8;
//				index += n;
//
//				if (id != idFormula) {
//					din.skip(n);
//				} else {
//					idSkill = din.readInt();
//					req_exp = din.readInt();
//					add_exp = din.readInt();
//					itemType1 = din.readInt();
//					itemCount1 = din.readByte();
//					itemType2 = din.readInt();
//					itemCount2 = din.readByte();
//					itemType3 = din.readInt();
//					itemCount3 = din.readByte();
//					productItemType = din.readInt();
//				}
//
//			} catch (IOException e) {
//				break;
//			}
//		}
//		try {
//			din.close();
////			is.close();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}

std::string FormulaMaterialData::getProductItemsName() 
{
	std::string res = "";
	if (productItemType != 0) {
		Item *item = new Item(productItemType);
		res = item->getItemName();
		delete item;
	}
	return res;
}

std::string FormulaMaterialData::getDetailDescription()
{
	std::stringstream sb;
	sb << NDCommonCString("NeedMaterial") << ":\n";
	if ((itemName1.empty()) && (itemType1 != 0)) {
		Item item(itemType1);
		itemName1 = item.getItemName();
	}
	if ((itemName2.empty()) && (itemType2 != 0)) {
		Item item(itemType2);
		itemName2 = item.getItemName();
	}
	if ((itemName3.empty()) && (itemType3 != 0)) {
		Item item(itemType3);
		itemName3 = item.getItemName();
	}
	
	if (!itemName1.empty()) {
		sb << itemName1 << "x " << itemCount1 << "\n";
	}
	if (!itemName2.empty()) {
		sb << itemName2 << "x " << itemCount2 << "\n";
	}
	if (!itemName3.empty()) {
		sb << itemName3 << "x " << itemCount3 << "\n";
	}
	
	sb << NDCommonCString("GenItem") << ":\n";
	sb << "<cf70a0f" << productItemName << "/e" << "\n";
	sb << Item(productItemType).makeItemDes(true);
	return sb.str();
}

void FormulaMaterialData::showDetailDialog()
{
	string strDetail = this->getDetailDescription();
	
	//ChatRecord.parserChat(sb.toString(),7)
	//dialog.setTitleCorlor(0xe5cc80);
	showDialog(formulaName.c_str(), strDetail.c_str());
}
