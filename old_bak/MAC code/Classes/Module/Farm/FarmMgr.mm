/*
 *  FarmMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FarmMgr.h"
#include "FarmStorage.h"
#include "NDTransData.h"
#include "NDUISynLayer.h"
#include "ItemMgr.h"
#include "NDItemType.h"
#include "NDNpc.h"
#include "NDMapMgr.h"
#include "HamletListScene.h"
#include "NDDirector.h"
#include "FarmInfoScene.h"
#include "FarmMessage.h"
#include "HarvestEvent.h"
#include "RanchProductDlg.h"
#include "GameStorageScene.h"
#include "SelectBagScene.h"
#include "GeneralListLayer.h"
#include "CGPointExtension.h"
#include "NDMiniMap.h"
#include <sstream>

namespace NDEngine
{
	#define PACKAGE_CONTINUE 0x00
	#define PACKAGE_BEGIN 0x01
	#define PACKAGE_END 0x02
	#define PACKAGE_SINGLE PACKAGE_BEGIN | PACKAGE_END
	
	
	IMPLEMENT_CLASS(NDFarmMgr, NDObject)
	
	NDFarmMgr::NDFarmMgr()
	{
		NDNetMsgPool& pool = NDNetMsgPoolObj;
		
		pool.RegMsg(_MSG_FARM_STORAGE, this);
		
		pool.RegMsg(_MSG_STORAGE_ACCESS, this);
		
		pool.RegMsg(_MSG_HAMLET, this);
		
		pool.RegMsg(_MSG_ENTER_HAMLET, this);
		
		pool.RegMsg(_MSG_FARM_LIST, this);
		
		pool.RegMsg(_MSG_FARM_PRODUCE, this);
		
		pool.RegMsg(_MSG_FARM_TRENDS, this);
		
		pool.RegMsg(_MSG_HARVEST, this);
		
		pool.RegMsg(_MSG_FARM_TIME_COUNT, this);
		
		pool.RegMsg(_MSG_FARM_MESSAGE_LIST, this);
		
		pool.RegMsg(_MSG_FARM_QUERY_MESSAGE, this);
		
		pool.RegMsg(_MSG_FARM_LEAVE_MESSAGE, this);
		
		pool.RegMsg(_MSG_FARM_MU_CHANG_OPT, this);
		
		pool.RegMsg(_MSG_FARM_MU_CHANG, this);
		
		pool.RegMsg(_MSG_FARM_MU_CHANG_PROD_OPT, this);
		
		pool.RegMsg(_MSG_UPDATE_FARM_TRENDS, this);
		
		pool.RegMsg(_MSG_UPDATE_MAP_NAME, this);
		
		pool.RegMsg(_MSG_MOVE_FARMLAND, this);
		
		pool.RegMsg(_MSG_MOVE_FARMLAND_NPC_LIST, this);
	}
	
	NDFarmMgr::~NDFarmMgr()
	{
	}
	
	void NDFarmMgr::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
	{
		if (dialog->GetTag() == muchangOpt.iDlg) 
		{
			if (buttonIndex < muchangOpt.opts.size()) 
			{
				NDTransData bao(_MSG_FARM_MU_CHANG);
				bao << int(muchangOpt.iFarmID) << int(muchangOpt.iEntity)
				<< (unsigned char)(muchangOpt.opts[buttonIndex].iAction)
				<< int(muchangOpt.opts[buttonIndex].iID);
				SEND_DATA(bao);
			}
			
			muchangOpt.iDlg = -1;
			dialog->Close();
		}
	}
	
	bool NDFarmMgr::process(MSGID msgID, NDTransData* data, int len)
	{
		switch (msgID) 
		{
			case _MSG_FARM_STORAGE:
				processFarmStorage(*data);
				break;
			case _MSG_STORAGE_ACCESS:
				processStorageAccess(*data);
				break;
			case _MSG_HAMLET:
				processHamlet(*data);
				break;
			case _MSG_ENTER_HAMLET:
				processEnterHamlet(*data);
				break;
			case _MSG_FARM_LIST:
				processFarmList(*data);
				break;
			case _MSG_FARM_PRODUCE:
				processFarmProduce(*data);
				break;
			case _MSG_FARM_TRENDS:
				processFarmTrends(*data);
				break;
			case _MSG_HARVEST:
				processFarmHarvest(*data);
				break;
			case _MSG_FARM_TIME_COUNT:
				processFarmTimeCount(*data);
				break;
			case _MSG_FARM_MESSAGE_LIST:
				processFarmMessageList(*data);
				break;
			case _MSG_FARM_QUERY_MESSAGE:
				processFarmQueryMessage(*data);
				break;
			case _MSG_FARM_LEAVE_MESSAGE:
				processFarmLeaveMessage(*data);
				break;
			case _MSG_FARM_MU_CHANG_OPT:
				processFarmMuChangOpt(*data);
				break;
			case _MSG_FARM_MU_CHANG:
				processFarmMuChang(*data);
				break;
			case _MSG_FARM_MU_CHANG_PROD_OPT:
				processFarmMuChangProdOpt(*data);
				break;
			case _MSG_UPDATE_FARM_TRENDS:
				processUpdateFarmTrends(*data);
				break;
			case _MSG_UPDATE_MAP_NAME:
				processUpdateMapName(*data);
				break;
			case _MSG_MOVE_FARMLAND:
				processMoveFarmLand(*data);
				break;
			case _MSG_MOVE_FARMLAND_NPC_LIST:
				processMoveFarmLandNpcList(*data);
				break;
			default:
				break;
		}
		
		return true;
	}
	
	void NDFarmMgr::processFarmStorage(NDTransData& data)
	{
		CloseProgressBar;
		Byte act=data.ReadByte();
		int freeSpace=data.ReadInt();
		int level=data.ReadInt();	
		
		Byte amount=data.ReadByte();
		switch(act){
			case 0://打开庄园仓库界面
			{
				FarmStorageDialog* fs=FarmStorageDialog::Show(level, freeSpace);
				for(int i=0;i<amount;i++){
					int ID=data.ReadInt();
					int idItemType=data.ReadInt();
					int num=data.ReadInt();
					int max=data.ReadInt();
					
					FarmEntityNode* farmentity = fs->AddFarmEntity(idItemType);
					
					farmentity->SetTag(ID);
					
					NDItemType *itemtype = ItemMgrObj.QueryItemType(idItemType);
					
					if (farmentity->GetTitleLabel()) 
						farmentity->GetTitleLabel()->SetText( itemtype ? itemtype->m_name.c_str() : "");
					
					NDUIStateBar* bar = farmentity->GetStateBar();
					if (bar) 
					{
						//bar->SetStateColor(INTCOLORTOCCC4(0x0066ff));
						//bar->SetBackgroundColor(ccc4(79, 79, 79, 255));
						bar->SetNumber(num, max, false);
						bar->SetLabelMaxNum(ccc4(255, 255, 255, 255), max);
						bar->SetLabelMinNum(ccc4(255, 255, 255, 255), num);
					}
					
					if(level<=2){ 
						if (farmentity->GetAddBtn()) {
							farmentity->GetAddBtn()->SetVisible(false);
						}
						if (farmentity->GetMinusBtn()) {
							farmentity->GetMinusBtn()->SetVisible(false);
						}
					}			
					//row.setChildOffset((byte)(level>2?10:20));		
					//					
					//					fs.addMaterial(row);	
				}
				
				//fs.iniMaxHeight();
				//				
				//				T.addToTop(fs);
			}
				break;
			case 1://更新庄园仓库界面
			{
				FarmStorageDialog* dlg = FarmStorageDialog::GetInstance();
				if (dlg) 
				{
					dlg->SetSpace(freeSpace);
					dlg->ClearOperateData();
					for (int i = 0; i < amount; i++) {
						FarmEntityNode* node = dlg->GetFarmEntity(data.ReadInt());
						if (node && node->GetStateBar()) {
							NDUIStateBar *bar = node->GetStateBar();
							bar->SetLabelMaxNum(ccc4(255, 255, 255, 255), data.ReadInt());
						}
					}
				}
			}
				break;
		}
	}
	
	void NDFarmMgr::processStorageAccess(NDTransData& data)
	{
		CloseProgressBar;
		Byte act = data.ReadByte();
		int itemID = data.ReadInt();
		int num = data.ReadInt();
		switch (act) {
			case 0:
			{
				// 存取消息更新
				FarmStorageDialog* dlg = FarmStorageDialog::GetInstance();
				if (dlg) 
				{
					FarmEntityNode* node = dlg->GetFarmEntity(itemID);
					if (node && node->GetStateBar()) {
						NDUIStateBar *bar = node->GetStateBar();
						bar->SetLabelMinNum(ccc4(255, 255, 255, 255), num);
					}
				}
				
				GameStorageUpdateFarm();
			}
				break;
		}
	}
	
	void NDFarmMgr::processHamlet(NDTransData& data)
	{
		int action = data.ReadByte();
		int flag = data.ReadByte();
		short curPage = (short) data.ReadShort();
		short sumPage = (short) data.ReadShort();
		int amount = data.ReadByte();
		
		if (flag == 1 || flag == 3) {
			m_vecHamletInfo.clear();
		}
		for (int i = 0; i < amount; i++) {
			int ID = data.ReadInt();
			int num = data.ReadInt();
			std::string name = data.ReadUnicodeString();
			HamletInfo info;
			info.idHamlet = ID;
			info.nNum = num;
			info.name = name;
			m_vecHamletInfo.push_back(info);
		}
		
		if (flag == 2 || flag == 3) {
			CloseProgressBar;
			//ListScreen list = new ListScreen("村落列表", FarmInfo.harmletArray,
//											 ListScreen.LIST_FOR_HAMLET);
//			list.setSumPage(sumPage);
//			list.setCurPage(curPage);
//			T.addToTop(list);
			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
			HamletListScene *hamlet = NULL;
			if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(HamletListScene))) 
			{
				hamlet = new HamletListScene;
				hamlet->Initialization();
				NDDirector::DefaultDirector()->PushScene(hamlet);
			}
			else 
			{
				hamlet = (HamletListScene*)scene;
			}
			
			hamlet->SetType(action == 0 ? HamletListScene_List : HamletListScene_Move);
			hamlet->SetPage(curPage, sumPage);
			hamlet->refresh();
		}
	}
	
	void NDFarmMgr::processEnterHamlet(NDTransData& data)
	{
		CloseProgressBar;
		int action = data.ReadByte();
		int iID = data.ReadInt();
		if (action == 5) {
			//移除怪物
			//GameScreen.getInstance().getScene().removePhantom(id);
			NDMonster* monster = NDMapMgrObj.GetMonster(iID);
			if (monster) 
			{
				NDMapMgrObj.ClearOneMonster(monster);
			}
		}
	}
	
	void NDFarmMgr::processFarmList(NDTransData& data)
	{
		CloseProgressBar;
		
		//package head
		int action = data.ReadByte();
		int flag = data.ReadByte();
		int amount = data.ReadByte();
		
		
		//if flag contain PACKAGE_BEGIN then
		//clear buildings or farms
		if (flag & PACKAGE_BEGIN) 
		{
			if (action == 0) //farms
			{
				m_farms.clear();
			}
			else //buildings 
			{
				m_buildings.clear();
			}
		}				
		
		//receive building  or farms info
		for (int i = 0; i < amount; i++) 
		{
			unsigned int idNpc = data.ReadInt();
			unsigned int unlookface = data.ReadInt();
			if (action == 0) //farms
			{
				m_farms.push_back(FarmInfo(idNpc, unlookface, data.ReadUnicodeString()));
			}
			else if (action == 1)//buildings 
			{
				int status = data.ReadByte();
				std::string name = data.ReadUnicodeString();
				m_buildings.push_back(FarmBuildingInfo(idNpc, unlookface, status, name));
			}
			else if (action == 2)
			{
				int x = data.ReadShort();
				int y = data.ReadShort();
				NDMonster* monster = NDMapMgrObj.GetMonster(idNpc);
				if (!monster) {
					monster = new NDMonster;
					monster->SetPosition(ccp(x*MAP_UNITSIZE, y*MAP_UNITSIZE));
					monster->Initialization(unlookface, idNpc, 1);
					monster->SetCanBattle(false);
					NDMapMgrObj.AddOneMonster(monster);
				}
				else 
				{
					monster->changeLookface(unlookface);
				}
				monster->SetCanBattle(false);
				//SceneMonster sm = GameScreen.getInstance().getScene()
//				.getSceneMonster(idNpc);
//				if (sm == null) {
//					sm = new SceneMonster(idNpc, x << 4, y << 4, unlookface);
//					GameScreen.getInstance().getScene().addElement(sm);
//				} else {
//					sm.changeLookface(unlookface);
//				}
			}
		}		
		
		//if flag contain PACKAGE_END then
		//to do operation with these buildings or farms
		if (flag & PACKAGE_END) 
		{
			if (action == 0) //farms
			{
				DealWithFarmInfos();				
			}
			else //buildings 
			{				
				DealWithBuildingInfos();				
			}
		}		
	}
	
	void NDFarmMgr::processFarmProduce(NDTransData& data)
	{
	}
	
	void NDFarmMgr::processFarmTrends(NDTransData& data)
	{
		int action = data.ReadByte();
		int flag = data.ReadByte();
		int amount = data.ReadByte();
		switch (action) {
			case 0:
				// in.readInt();
				for (int i = 0; i < amount; i++) {
					int itemType = data.ReadInt();
					int total = data.ReadInt();
					int wh = data.ReadInt();
					FarmInfoLayer::addFarmTotalResource(itemType, total, wh);
				}
				break;
			case 1:
				for (int i = 0; i < amount; i++) {
					int idNpc = data.ReadInt();
					std::string name = data.ReadUnicodeString();
					int level = data.ReadByte();
					int tTime = data.ReadInt();
					int rTime = data.ReadInt();
					std::stringstream sb;
					if (level == 1) {
						sb << NDCommonCString("build") << "-";
					} else {
						sb << NDCommonCString("up") << "-";
					}
					
					sb << level << NDCommonCString("Ji") << name;
					FarmInfoLayer::addState(3, sb.str(), tTime, rTime, idNpc);
				}
				
				break;
			case 2:
				for (int i = 0; i < amount; i++) {
					int idNpc = data.ReadInt();
					std::string name = data.ReadUnicodeString();
					std::string cName = data.ReadUnicodeString();
					int level = data.ReadByte();
					int tTime = data.ReadInt();
					int rTime = data.ReadInt();
					std::stringstream sb;
					sb << name << "-";
					sb << int(level) << NDCommonCString("Ji") << cName;
					FarmInfoLayer::addState(4, sb.str(), tTime, rTime, idNpc);
				}
				break;
		}
		
		if (flag == 2 || flag == 3) {
			FarmInfoLayer* farminfo = FarmInfoLayer::GetInstance();
			if (farminfo)
			{
				farminfo->RefreshState();
				farminfo->RefreshResurce();
			}
				
		}
	}
	
	void NDFarmMgr::processFarmHarvest(NDTransData& data)
	{
		int type = data.ReadInt();
		int num = data.ReadInt();
		NDItemType* obj = ItemMgrObj.QueryItemType(type);
		if (!obj) return; 
		
		int iconIndex = obj->m_data.m_iconIndex;
		//int imageRowIndex = iconIndex / 100 - 1;
//		int imageColIndex = iconIndex % 100 - 1;
		//EventShow s = new EventShow(ItemView.items, "+" + num, imageRowIndex,
//									imageColIndex);
//		GameScreen.role.addEventAdd(s);
		iconIndex = (iconIndex % 100 - 1) + (iconIndex / 100 - 1) * 6;
		HarvestEventMgrObj.AddHarvestEvent(iconIndex, num);
	}
	
	void NDFarmMgr::processFarmTimeCount(NDTransData& data)
	{
		//BytesArrayInput in = new BytesArrayInput(data);
//		int total = in.readInt();
//		int left = in.readInt();
//		String label = in.readString();
//		fs = new FarmStatus(label, total, left);
		fs.bNew = true;
		fs.total = data.ReadInt();
		fs.left = data.ReadInt();
		fs.title = data.ReadUnicodeString();
	}
	
	void NDFarmMgr::processFarmMessageList(NDTransData& data)
	{
		int type = data.ReadByte();
		int farmId = data.ReadInt();
		int curPage = data.ReadShort();
		int sumPage = data.ReadShort();
		int count = data.ReadByte();
		
		FarmMsgListScene* scene = QueryFarmMsgListScene(type);
		
		if (!scene && !(scene = CreateFarmMsgListScene(type))) 
		{
			return;
		}
		
		for (int i = 0; i < count; i++) 
		{
			int iID = -1;
			if (type == FarmMessage_User || type == FarmMessage_Self) 
			{
				iID = data.ReadInt();
			}
			std::string text = data.ReadUnicodeString();
			scene->AppendRecord(iID, text);
		}
		
		scene->setCurPage(curPage);
		scene->setSumPage(sumPage);
		scene->SetFarmID(farmId);
		
		CloseProgressBar;
	}
	
	void NDFarmMgr::processFarmQueryMessage(NDTransData& data)
	{
		int type=data.ReadByte();
		/*int action=*/data.ReadByte();
		/*int farmId=*/data.ReadInt();
		int iID=data.ReadInt();
		
		
		FarmMsgListScene* scene = QueryFarmMsgListScene(type);
		if (scene) {
			scene->DelRecord(iID);
		}
		//if(ListScreen.instance!=null&&ListScreen.instance.mode==type&&ListScreen.instance.farmId==farmId){
//			ListScreen.instance.removeData(type, id);
//		}
	}
	
	void NDFarmMgr::processFarmLeaveMessage(NDTransData& data)
	{
	}
	
	void NDFarmMgr::processFarmMuChangOpt(NDTransData& data)
	{
		CloseProgressBar;
		
		muchangOpt.opts.clear();
		muchangOpt.iFarmID = data.ReadInt();
		muchangOpt.iEntity = data.ReadInt();
		
		int count = data.ReadByte();
		
		std::vector<std::string> vec_str;
		
		for (int i = 0; i < count; i++) {
			FarmMuChangOpt::opt opt;
			opt.iAction = data.ReadByte();
			opt.iID = data.ReadInt();
			vec_str.push_back(data.ReadUnicodeString());
			muchangOpt.opts.push_back(opt);
		}
		
		std::string title = data.ReadUnicodeString();
		std::string content = data.ReadUnicodeString();
		
		muchangOpt.iDlg = GlobalDialogObj.Show(this, title.c_str(), content.c_str(), 0, vec_str);
	}
	
	void NDFarmMgr::processFarmMuChang(NDTransData& data)
	{
	}
	
	void NDFarmMgr::processFarmMuChangProdOpt(NDTransData& data)
	{
		int farmId = data.ReadInt();
		int entityId = data.ReadInt();
		int productId = data.ReadInt();
		// int optNum = in.read();
		int harvest = data.ReadByte();
		
		RanchProductDlg *dlg = new RanchProductDlg;
		dlg->Initialization(farmId, entityId, productId, harvest != 0);
		
		if (harvest == 0) {
			int restTime = data.ReadInt();
			int totalTime = data.ReadInt();
			std::string label = data.ReadUnicodeString();
			dlg->AddStatus(label, totalTime, restTime);
		}
		// for (int i = 0; i < optNum; i++) {
		// int type = in.readInt();
		// String opt = in.readString();
		// }
		std::string title = data.ReadUnicodeString();
		std::string content = data.ReadUnicodeString();
		
		dlg->Show(title, content);
	}
	
	void NDFarmMgr::processUpdateFarmTrends(NDTransData& data)
	{
		CloseProgressBar;
		FarmInfoLayer * farminfo = FarmInfoLayer::GetInstance();
		if (farminfo) 
		{
			unsigned char act = 0; 
			int iID = 0;
			data >> act >> iID;
			if (act == 0) {
				farminfo->cancelBuilding(iID);
			} else if (act == 1) {
				farminfo->addBuildSpeed(iID, data.ReadInt());
			}
		}
	}
	
	void NDFarmMgr::processUpdateMapName(NDTransData& data)
	{
		std::string name = data.ReadUnicodeString();
		
		//NDMiniMap* minimap = NDMiniMap::GetInstance();
//		
//		if (minimap) minimap->SetMapName(name);
		
		NDMapMgrObj.mapName = name;
	}
	
	void NDFarmMgr::processMoveFarmLand(NDTransData& data)
	{
	}
	
	void NDFarmMgr::processMoveFarmLandNpcList(NDTransData& data)
	{
		CloseProgressBar;
		int hamletId = data.ReadInt();
		int amount = data.ReadByte();
		m_vecEmptyHamletInfo.clear();
		for (int i = 0; i < amount; i++) {
			int idNpc = data.ReadInt();
			std::string name = data.ReadUnicodeString();
			m_vecEmptyHamletInfo.push_back(HamletInfo());
			HamletInfo& info = m_vecEmptyHamletInfo.back();
			info.idNPc = idNpc;
			info.nNum = 0;
			info.name = name;
			info.idHamlet = hamletId;
		}
		GeneralListLayer::processEmpytHamlet(NDCString("EmptySpaceList"), m_vecEmptyHamletInfo);
		//ListScreen list = new ListScreen("空地列表", FarmEntityInfo.emptyFarmArray,
//										 ListScreen.LIST_FOR_EMPTY_FARMS);
//		list.setSumPage(1);
//		list.setCurPage(0);
//		T.addToTop(list);
	}
	
	void NDFarmMgr::UpdateNpcLookface(unsigned int idNpc, unsigned int newLookface)
	{
	}
	
	void NDFarmMgr::DealWithBuildingInfos()
	{
		std::vector<FarmBuildingInfo>::iterator iter;
		for (iter = m_buildings.begin(); iter != m_buildings.end(); iter++) 
		{
			const FarmBuildingInfo& building = *iter;
			NDMapMgrObj.UpdateNpcLookface(building.idNpc, building.lookface);
			NDNpc* npc = NDMapMgrObj.GetNpc(building.idNpc);
			if (npc) 
			{
				npc->SetActionOnRing(false);
				npc->SetDirectOnTalk(false);
				npc->SetStatus(building.upLevel);
				npc->m_name = building.name;
				npc->SetFarmNpc(true);
			}
		}
	}
	
	void NDFarmMgr::DealWithFarmInfos()
	{
		std::vector<FarmInfo>::iterator iter;
		for (iter = m_farms.begin(); iter != m_farms.end(); iter++) 
		{
			const FarmInfo& farm = *iter;	
			NDMapMgrObj.UpdateNpcLookface(farm.idNpc, farm.lookface);
			NDNpc* npc = NDMapMgrObj.GetNpc(farm.idNpc);
			if (npc) 
			{
				npc->SetActionOnRing(false);
				npc->SetDirectOnTalk(false);
				npc->m_name = farm.name;
				npc->SetFarmNpc(true);
			}
		}
	}
	
	
	/////////////////////////////////////////////////////
	VEC_ITEM deleteSameItemType(VEC_ITEM& itemList) {
		int size = itemList.size();
		Item *item = NULL;
		Item *t_item = NULL;
		int t_size;
		bool isHaveSame;
		VEC_ITEM t_itemList;
		for (int i = 0; i < size; i++) {
			item = itemList[i];
			t_size = t_itemList.size();
			isHaveSame = false;
			for (int j = 0; j < t_size; j++) {
				t_item = t_itemList[j];
				if (item->iItemType == t_item->iItemType) {
					isHaveSame = true;
					break;
				}
			}
			if (!isHaveSame) {
				t_itemList.push_back(item);
			}
		}
		return t_itemList;
	}
	
	VEC_ITEM filterItem(vector<Item*>& itemlist, vector<int> filter)
	{
		vector<Item*> vec_item;
		vector<Item*>::iterator it = itemlist.begin();
		for (; it != itemlist.end(); it++) 
		{
			vector<int> vec_type = Item::getItemType((*it)->iItemType);
			int typesize = vec_type.size();
			int filtersize = filter.size();
			for (int i = 0; i < filtersize; i++) 
			{
				if (i > (typesize-1) || filter[i] != vec_type[i]) 
				{
					break;
				}
				
				if (i == filtersize-1) 
				{
					vec_item.push_back(*it);
				}
			}
		}
		
		return vec_item;
	}
	
	void showGeneralDialog(VEC_ITEM& itemList,std::string title, std::string errorMessage,int npcId, int type)
	{
		if(itemList.empty()){
			showDialog(NDCommonCString("WenXinTip"), errorMessage.c_str());
		}else{
			std::vector<std::string> vec_str;
			vec_str.push_back(NDCommonCString("name"));
			vec_str.push_back(NDCommonCString("require"));
			vec_str.push_back(NDCString("ChengShouTime"));
			
			VEC_ITEM items = deleteSameItemType(itemList);
			GeneralListLayer::processFarmList(title, items, vec_str, npcId, type);
			//byte showAmount=3;
//			GeneralDialog gl=GeneralDialog.getInstance(type);
//			gl.setTitle(title);
//			Array t_itemList =deleteSameItemType(itemList);
//			int curCount=t_itemList.size();
//			gl.allCount =curCount;
//			gl.itemList=t_itemList;
//			
//			ListField fields[] = new ListField[showAmount];
//			fields[0] = gl.new ListField();
//			fields[0].type = (byte)1;
//			fields[0].name = NDCommonCString("name");
//			
//			fields[1] = gl.new ListField();
//			fields[1].type = (byte)0;
//			fields[1].name = NDCommonCString("require");
//			
//			fields[2] = gl.new ListField();
//			fields[2].type = (byte)0;
//			fields[2].name = NDCString("ChengShouTime");
//			
//			gl.setFields(fields);
//			
//			T.listRecords = new Array();
//			T.listRecords.addElement(new Integer(npcId));
//			
//			for (int i = 0; i < curCount; i++) {
//				Item item = (Item) t_itemList.elementAt(i);
//				T.listRecords.addElement(item.getItemName());
//				String s="";
//				if(type==0){
//					s="农田";
//				}else if(type==1){
//					s="牧场";
//				}
//				T.listRecords.addElement(s + item.getItemTypes().itemLevel + NDCommonCString("Ji"));
//				T.listRecords.addElement(item.getItemTypes().suitData + "分钟");
//			}
//			gl.makeContent();
//			T.addToTop(gl);
		}
	}
	
	void showSelectBag(VEC_ITEM& itemList,std::string title, std::string errorMessage,int npcId, int type)
	{
		if(itemList.empty()){
			showDialog(NDCommonCString("WenXinTip"), errorMessage.c_str());
		}else{
			SelectBagScene *scene = new SelectBagScene;
			scene->Initialization(type, npcId);
			NDDirector::DefaultDirector()->PushScene(scene);
		}
	}
	
	void showUseItemUI(int npcId,int type)
	{
		VEC_ITEM itemList = ItemMgrObj.GetPlayerBagItems();
		std::vector<int> rules;
		switch (type) {
			case 0:
			{
				rules.push_back(8); rules.push_back(3); rules.push_back(0); rules.push_back(1);
				itemList=filterItem(itemList, rules);
				showGeneralDialog(itemList,NDCommonCString("ZhongZhi"),NDCString("ZhongZhiTip"),npcId,type);
			}
				break;
			case 2:
			{
				rules.push_back(8); rules.push_back(2); rules.push_back(0); rules.push_back(2);
				itemList=filterItem(itemList, rules);
				showSelectBag(itemList,NDCommonCString("ShiFei"),NDCString("ShiFeiTip"),npcId,type);
			}
				break;
			case 1:
			{
				rules.push_back(8); rules.push_back(3); rules.push_back(0); rules.push_back(2);
				itemList=filterItem(itemList, rules);
				showGeneralDialog(itemList,NDCommonCString("YangZhi"),NDCString("YangZhiTip"),npcId,type);
			}
				break;
			case 3:
			{
				rules.push_back(8); rules.push_back(2); rules.push_back(0); rules.push_back(3);
				itemList=filterItem(itemList, rules);
				showSelectBag(itemList,NDCommonCString("WeiSiLiao"),NDCString("WeiSiLiaoTip"),npcId,type);
			}
				break;
			case 4:
			case 5:
			{
				rules.push_back(8); rules.push_back(2); rules.push_back(0); rules.push_back(6);
				itemList=filterItem(itemList, rules);
				showSelectBag(itemList,NDCommonCString("JiaSuUp"),NDCString("JiaSuUpTip"),npcId,type);
			}
				break;
		}
	}
}