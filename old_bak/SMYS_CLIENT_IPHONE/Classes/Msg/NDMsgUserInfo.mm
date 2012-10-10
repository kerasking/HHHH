/*
 *  NDMsgUserInfo.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgUserInfo.h"
#include "NDMsgDefine.h"
#include "NDPlayer.h"
#include "CGPointExtension.h"
#include "NDMapLayer.h"
#include "NDDirector.h"
#include "NDMapMgr.h"
#include "NDItemType.h"

using namespace NDEngine;

void NDMsgUserInfo::Process(NDTransData* data, int len)
{	
	int id = 0; (*data) >> id; // 用户id 4个字节
	int dwLookFace = 0; (*data) >> dwLookFace; // 创建人物的时候有6种外观可供选择外观 脸型
	int nLife = 0; (*data) >> nLife; // 生命值4个字节
	int nMaxLife = 0; (*data) >> nMaxLife;// 最大生命值4个字节
	int nMana = 0; (*data) >> nMana; // 魔法值
	
	int nMaxMana = 0; (*data) >> nMaxMana; // 最大魔法值
	
	int nMoney = 0; (*data) >> nMoney; // 银两 4个字节
	unsigned char btLevel = 0; (*data) >> btLevel; // 用户等级
	unsigned short usRecordX = 0; (*data) >> usRecordX; // 记录点信息X
	unsigned short usRecordY = 0; (*data) >> usRecordY; // 记录点信息Y
	int idRecordMap = 0; (*data) >> idRecordMap; // 记录点的地图 id
	int dwWeapid = 0; (*data) >> dwWeapid; // 武器 4个字节
	int dwArmorType = 0; (*data) >> dwArmorType;; // 盔甲id 4个字节
	unsigned char btProfession = 0; (*data) >> btProfession; // 玩家的职业 1个字节
	int dwEMoney = 0; (*data) >> dwEMoney; // 元宝 4个字节
	int storageMoney = 0; (*data) >> storageMoney; // 仓库银两4个字节
	int storageEMoney = 0; (*data) >> storageEMoney; // 仓库元宝4个字节
	int dwPhyPoint = 0; (*data) >> dwPhyPoint; // 力量点4个字节
	int dwDexPoint = 0; (*data) >> dwDexPoint; // 敏捷点4个字节
	int dwMagPoint = 0; (*data) >> dwMagPoint; // 智力点4个字节
	int dwDefPoint = 0; (*data) >> dwDefPoint; // 防御点4个字节
	int dwExp = 0; (*data) >> dwExp;// 经验值4个字节
	int dwLevelUpExp = 0; (*data) >> dwLevelUpExp;// 下次升级所需经验
	int dwResetPoint = 0; (*data) >> dwResetPoint; // 剩余点数 4个字节
	int dwSkillPoint = 0; (*data) >> dwSkillPoint;// 灵气值
	int dwPkPoint = 0; (*data) >> dwPkPoint; // pk值
	unsigned char btCamp = 0;(*data) >> btCamp;  // 阵营
	
	std::string name = data->ReadUnicodeString();
	
	NDPlayer::defaultHero().m_id = id;
	NDPlayer::defaultHero().Initialization(dwLookFace);

	//NSLog(@"%d", layer->GetChildren().size()); 
	
	NDPlayer::defaultHero().stopMoving();
	NDPlayer::defaultHero().SetPosition(ccp(usRecordX*16+8, usRecordY*16+8));
	NDPlayer::defaultHero().SetServerPositon(usRecordX, usRecordY);
	

	//NSLog(@"玩家名字:%@", [NSString stringWithUTF8String:name.c_str()]);
}

void NDMsgUserItemInfo::Process(NDTransData* data, int len)
{
	unsigned char itemCount = 0; (*data) >> itemCount; // 接收的物品个数
	
	for (int j = 0; j < itemCount; j++) {
		int itemID = 0; (*data) >> itemID; // 物品的Id 4个字节
		int ownerID = 0; (*data) >> ownerID; // 物品的所有者id 4个字节
		int itemType = 0; (*data) >> itemType; // 物品类型 id 4个字节
		int dwAmount = 0; (*data) >> dwAmount;// 物品数量/耐久度 4个字节
		int itemPosition = 0; (*data) >> itemPosition; // 物品位置 4个字节
		int btAddition = 0; (*data) >> btAddition; // 装备追加 4个字节
		unsigned char bindState = 0; (*data) >> bindState; // 绑定状态
		unsigned char btHole = 0; (*data) >> btHole; // 装备有几个洞
		int createTime = 0; (*data) >> createTime; // 创建时间
		unsigned char sAge = 0; (*data) >> sAge;// 骑宠寿命
		unsigned char stoneCount = 0; (*data) >> stoneCount;
		if (stoneCount > 0) 
		{
			for (int i = 0; i < stoneCount; i++) 
			{
				int stoneID = 0; (*data) >> stoneID;
			}
		}
		
		if (itemPosition == 90) 
		{ // 仓库
			continue;
		} else if (itemPosition == 92) 
		{ // 邮件物品
		} else if (itemPosition == 91) 
		{ // 之前拍卖的,暂时先加上,防止数据库 有之前的脏数据,
			// 如果正常运行是不会有91的值出现
		} else 
		{ // 增加的是背包中的物品
			// 增加到背包中
			if (itemPosition == 0) 
			{// 背包中的
			} else 
			{// 装备上的
				//todo
				
				NDItemType* item = NDMapMgrObj.QueryItemType(itemType);
				
				if (!item ) 
				{
					continue;
				}
				
				int nID = item->m_data.m_lookface;
				int quality = itemType % 10;;
				
				if (nID == 0) 
				{
					continue;
				}
				int aniId = 0;
				if (nID > 100000) 
				{
					aniId = (nID % 100000) / 10;
				}
				if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000) 
				{// 战宠
				} else 
				{
					NDPlayer::defaultHero().SetEquipment(nID, quality);
				}
				
				
				//NDPlayer::defaultHero().SetEquipment(int equipmentId, int quality);
			}
		}
		
	}
}

void NDMsgUserAttrib::Process(NDTransData* data, int len)
{
	int idUser = 0; (*data) >> idUser;
	
	//if (idUser != GameScreen.role.getId()) { // 如果不是自己玩家的id不处理
	//	return;
	//}
	
	unsigned char dwAttributeNum = 0; (*data) >> dwAttributeNum; // 1字节
	
	for (int i = 0; i < dwAttributeNum; i++)
	{
		int ucAttributeType = 0; (*data) >> ucAttributeType;
		int dwAttributeData = 0; (*data) >> dwAttributeData;
		
		switch (ucAttributeType)
		{
			case NDServerCode::USERATTRIB_MONEY:
			{
				break;
			}
			case NDServerCode::USERATTRIB_EMONEY:
			{
				break;
			}
			case NDServerCode::USERATTRIB_MAXLIFE:
			{
				break;
			}
			case NDServerCode::USERATTRIB_LIFE: 
			{
				break;
			}
			case NDServerCode::USERATTRIB_MAXMANA:
			{
				break;
			}
			case NDServerCode::USERATTRIB_MANA:
			{
				break;
			}
			case NDServerCode::USERATTRIB_LEV:
			{
				break;
			}
			case NDServerCode::USERATTRIB_EXP:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_PK:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_PK_ENABLE:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_PHY_POINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_DEX_POINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_MAG_POINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_DEF_POINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_ADDPOINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_EXPMEDICAL_LEVEL:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_SKILL_POINT:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_STATUS:
			{
				
				break;
			}
			case NDServerCode::USERATTRIB_CAMP:
			{
				
				break;
			}
		}
	}
}

void NDMsgUserWalk::Process(NDTransData* data, int len)
{
	if (!data || len == 0) return ;
	
	int nID = 0; (*data) >> nID;
	unsigned char dir = 0; (*data) >> dir;
	
	if ( nID != NDPlayer::defaultHero().m_id) 
	{
		NDManualRole *role = NULL;
		role = NDMapMgrObj.GetManualRole(nID);
		if ( role ) 
		{
			int usRecordX = role->GetPosition().x/16;
			int usRecordY = role->GetPosition().y/16;
			switch(dir)
			{
				case 0:
					usRecordY--;
					break;
				case 1:
					usRecordY++;
					break;
				case 2:
					usRecordX--;
					break;
				case 3:
					usRecordX++;
			}
			role->Walk(ccp(usRecordX*16, usRecordY*16), SpriteSpeedStep4);
		}
		
		return;
	}
	
	NDPlayer::defaultHero().SetServerDir(dir);
}

void NDMsgKickBack::Process(NDTransData* data, int len)
{
	if (!data || len == 0) return ;
	
	unsigned short usRecordX = 0; (*data) >> usRecordX;
	unsigned short usRecordY = 0; (*data) >> usRecordY;
	
	NDPlayer::defaultHero().stopMoving();
	NDPlayer::defaultHero().SetPosition(ccp(usRecordX*16+8, usRecordY*16+8));

	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene( NDDirector::DefaultDirector()->GetRunningScene());
	if (!layer) 
	{
		return;
	}
	
	layer->SetScreenCenter(ccp(usRecordX*16+8, usRecordY*16+8));
}


//////////////////////////////////////////////////////////////
void NDMsgBrocastPlayer::Process(NDTransData* data, int len)
{
	if (!data || len == 0) return ;
	
	int id = 0; (*data) >> id; // 用户id 4个字节
	int nLife = 0; (*data) >> nLife; // 生命值4个字节
	int nMaxLife = 0; (*data) >> nMaxLife; // 生命值4个字节
	int nMana = 0; (*data) >> nMana; // 魔法值
	int nMoney = 0; (*data) >> nMoney; // 银两 4个字节
	int dwLookFace = 0; (*data) >> dwLookFace; // 创建人物的时候有6种外观可供选择外观 脸型 4个字节
	unsigned short usRecordX = 0; (*data) >> usRecordX; // 记录点信息X
	unsigned short usRecordY = 0; (*data) >> usRecordY; // 记录点信息Y
	unsigned char btDir = 0; (*data) >> btDir; // 玩家面部朝向，左右两个方向 1个字节
	unsigned char btProfession = 0; (*data) >> btProfession; // 玩家的职业 1个字节
	unsigned char btLevel = 0; (*data) >> btLevel; // 用户等级
	int dwState = 0; (*data) >> dwState; // 状态位
	// System.out.println(" 状态 " + dwState);
	int synRank = 0; (*data) >> synRank; // 帮派等级
	int dwArmorType = 0; (*data) >> dwArmorType; // 盔甲id 4个字节
	int dwPkPoint = 0; (*data) >> dwPkPoint;// pk值
	unsigned char btCamp = 0; (*data) >> btDir; // 阵营
	std::string name = "";
	std::string rank = "";
	std::string synName = ""; // 帮派名字
	
	unsigned char n = 0; (*data) >> btDir; // TQMB 个数 1字节
	for (int i = 0; i < n; i++) 
	{
		std::string str = data->ReadUnicodeString();
		if (i == 0) 
		{
			name = str;
		} else if (i == 1 && str.length() > 2) 
		{
			rank = str;
		} else if (i == 2) 
		{
			synName = str;
		}
	}
	
	NDManualRole *role = NULL;
	role = NDMapMgrObj.GetManualRole(id);
	if ( !role ) 
	{
		role = new NDManualRole;
		role->m_id = id;
		role->Initialization(dwLookFace);
		NDMapMgrObj.AddManualRole(id, role);
	}
	
	role->SetPosition(ccp(usRecordX*16, usRecordY*16));
	role->SetSpriteDir(btDir);
	
	// int dwTransFormLookFace = 0; (*data) >> dwLookFace; // 变形成怪物
	
	// msg end
	
	// T.DEBUG("******* name = " + name);
	// T.DEBUG("******* synName = " + synName);
	// T.DEBUG("******* synRank = " + synRank);
	//
	// T.writeLog("dwLookFace " + dwLookFace);
	// T.writeLog("生命值 " + nLife);
	// T.writeLog("最大生命值 " + nMaxLife);
	
	//int sex = ManualRole.getSexByLookface(dwLookFace); // 性别
	//int skinColor = ManualRole.getSkinColorByLookface(dwLookFace);// 肤色
	//int hairColor = ManualRole.getHairColorByLookface(dwLookFace);// 发色
    //int hair = ManualRole.getHairByLookface(dwLookFace);// 头发
	
	// T.writeLog(" 人物性别(1-男性，2-女性): " + sex);
	// T.writeLog(" 肤色: " + skinColor);
	// T.writeLog(" 发色: " + hairColor);
	// T.writeLog(" hair: " + hair);
	//
	// T.writeLog("  添加人物 name:" + name + " id:" + id + " col:" + usRecordX
	// + " row:" + usRecordY + " dir:" + btDir);
	/*
	if (id != role.getId()) {
		
		// 不安全
		ManualRole player = Scene.getRole(id);
		
		if (player == null) {
			player = new ManualRole();
			player.setSex(sex);
			player.playerInit();
		}
		
		player.setVisible(true);
		player.setPosition(usRecordX, usRecordY);
		
		// player.setMaxMana(maxMana)
		player.setMaxLife(nMaxLife);
		player.setId(id);
		player.setLife(nLife);
		player.setMana(nMana);
		player.setMoney(nMoney);
		player.setDirect(btDir);
		player.setProfession(btProfession);
		player.setLevel(btLevel);
		player.setName(name);
		player.setRank(rank);
		
		player.setSex(sex);
		player.setHairColor(hairColor - 1); // 发色
		player.setHair(hair); // 发型
		player.setSkinColor(skinColor - 1); // 肤色
		
		player.teamId = dwArmorType;
		if (DepolyCfg.debug) {
			System.out.println(" team id :" + dwArmorType);
		}
		player.setPkPoint(dwPkPoint); // pk值
		player.setCamp(btCamp); // 阵营 1,2
		player.setState(dwState);
		if (synName != null) {
			player.setSynName(synName);
			player.setSynRank((byte) synRank);
		} else {
			player.setSynName(null);
			player.setSynRank(SyndicateElement.RANK_NONE);
		}
		scene.addPlayer(player);
		// scene.addPlayerToList(player);
		
		if ((dwState & ManualRole.USERSTATE_TRANSFORM) > 0) {
			player.updateTransform(in.readInt());
		}
		
	} else {
		role.setPosition(usRecordX, usRecordY);
		role.setState(dwState);
	}
	 */
}

void NDMsgPlayerExt::Process(NDTransData* data, int len)
{
	if (!data || len == 0) return ;

	// 其它用户状态
	int idUser = 0; (*data) >> idUser;

	int dwStatus = 0; (*data) >> dwStatus;

	NDManualRole *role = NULL;
	role = NDMapMgrObj.GetManualRole(idUser);
	if ( !role ) 
	{
		return;
	}
	
	// 其他人的装备信息
	unsigned char btAmount = 0; (*data) >> btAmount; //一字节
	
	for (int i = 0; i < btAmount; i++) 
	{
		int equipTypeId = 0; (*data) >> equipTypeId; // todo:根据装备id,判断属于哪个部位
		NDItemType* item = NDMapMgrObj.QueryItemType(equipTypeId);
		
		if (!item) 
		{
			continue;
		}
		
		int nID = item->m_data.m_lookface;
		int quality = equipTypeId % 10;
		
		if (nID == 0) 
		{
			continue;
		}
		int aniId = 0;
		if (nID > 100000) 
		{
			aniId = (nID % 100000) / 10;
		}
		if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000) 
		{// 战宠
		} else 
		{
			role->SetEquipment(nID, quality);
		}

		//Item item = new Item(equipTypeId);
		// int lookface = new Item(equipTypeId).getLookface();
		
		// scene.updatePlayerEquipment(idUser, item);
		//player.setEquipmentLookFace(item);
		
		//todo
		//int lookface = 0;
		//role->SetEquipment(int equipmentId, int quality);
		
	}
	
	/* todo:是否读变身id
	if ((dwStatus & ManualRole.USERSTATE_TRANSFORM) > 0) {
		player.updateTransform(in.readInt());
	} else {
		player.updateTransform(0);
	}
	*/
	
	// msg end
}

void NDMsgPlayerDisappear::Process(NDTransData* data, int len)
{
	if (!data || len == 0) return ;
	
	int idUser = 0; (*data) >> idUser;
	
	NDMapMgrObj.DelManualRole(idUser);
}

