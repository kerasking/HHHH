/*
 *  NDMsgMonster.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgMonster.h"
#include "NDNpc.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#include "NDMapLayer.h"
#include "NDMapData.h"
#include "NDDirector.h"
#include "NDMonster.h"
using namespace NDEngine;

void NDMsgMonster::Process(NDTransData* data, int len)
{
	unsigned char btAction = 0; (*data) >> btAction;
	unsigned char count = 0;  (*data) >> count;
	if (btAction == 0)
	{
		for (int i = 0; i < count; i++)
		{
			int idType = 0; (*data) >> idType;
			int lookFace = 0; (*data) >> lookFace;
			unsigned char lev = 0; (*data) >> lev;
			unsigned char  btAiType = 0; (*data) >> btAiType;
			unsigned char  btCamp = 0; (*data) >> btCamp;
			unsigned char  btAtkArea = 0; (*data) >> btAtkArea;
			std::string name = data->ReadUnicodeString(); //这个字符串可能需要做修改
			//NSLog(@"%@", [NSString stringWithUTF8String:name.c_str()]);
			
			monster_type_info info;//{idType, lookFace, lev, btAiType, btCamp, btAtkArea, name};
			info.idType = idType;
			info.lookFace = lookFace;
			info.lev = lev;
			info.btAiType = btAiType;
			info.btCamp = btCamp;
			info.btAtkArea = btAtkArea;
			info.name = name;
			if (lookFace == 19070 || lookFace == 206) continue;
	
			NDMapMgrObj.m_mapMonsterInfo.insert(monster_info_pair(idType, info));
			/*
			NDNpc *npc = new NDNpc;
			
			npc->Initialization(usLook);
			npc->SetPosition(ccp(usCellX*16, usCellY*16));
			NDMapMgrObj.m_vMonster.push_back(npc);
			*/
			
			//String name = in.readString2();
			//String[] info = { name, "" + lookFace, "" + lev, "" + btAiType,
			//	"" + btCamp, "" + btAtkArea };
			//AnimationShop.getInstance().addMonsterType(idType, info);
		}
	} else if (btAction == 1)
	{
		for (int i = 0; i < count; i++)
		{
			int idMonster  = 0; (*data) >> idMonster;
			int idType = 0; (*data) >> idType;
			unsigned short col = 0; (*data) >> col;
			unsigned short row = 0; (*data) >> row;
			unsigned char  btState = 0; (*data) >> btState;
			
			NDLayer *layer = NDMapMgrObj.getMapLayerOfScene( NDDirector::DefaultDirector()->GetRunningScene());
			if (!layer)
			{
				int a=0;
				a++;
				return;
			}
			NDMapData *mapdata = ((NDMapLayer*)layer)->GetMapData();
			NDTile* tile = [mapdata getTileAtRow:row column:col];
			if (!tile) 
			{
				NSLog(@"怪物的坐标有问题");
				continue;
			}
			
			if (idType / 1000000 == 6) {
				// 采集
				continue;
			}
			
			monster_type_info info;
			if ( !NDMapMgrObj.GetMonsterInfo(info, idType) ) continue;
			//NSLog(@"怪物的坐标(%d,%d)",row, col );
			NDMonster *monster = new NDMonster;
			monster->m_id = idMonster;
			monster->Initialization(idType);
			monster->SetPosition(ccp(col*16, row*16));
			NDMapMgrObj.m_vMonster.push_back(monster);
			
			//if (SceneMonster.isCollection(idType))
			//{ // 如果是采集点
				/*
				GatherPoint gp = null;
				if (idMonster > 0) {
					gp = GameScreen.getInstance().getScene()
					.getGatherPoint(idMonster);
				}
				if (gp == null) {
					gp = new GatherPoint(idMonster, idType, col << 4,
										 row << 4, idMonster > 0, "");
					GameScreen.getInstance().getScene().addElement(gp);
				}
				gp.setState(btState);*/
			//} else
			//{
				/*
				SceneMonster sm = null;
				if (idMonster > 0) {
					sm = GameScreen.getInstance().getScene()
					.getSceneMonster(idMonster);
				}
				if (sm == null) {
					sm = new SceneMonster(idType, col << 4, row << 4,
										  idMonster > 0, idMonster, i);
					GameScreen.getInstance().getScene().addElement(sm);
				}
				if (idMonster > 0) {
					sm.setState(btState);
				}
				 */
			//}
			
		}
		NDMapMgrObj.AddAllMonsterToMap();
		
	} else
	{
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0; (*data) >> idMonster;
			unsigned char btState = 0; (*data) >> btState;
			if (idMonster > 0)
			{
				/*
				SceneElement se = GameScreen.getInstance().getScene()
				.getGatherPoint(idMonster);
				if (se == null) {
					se = GameScreen.getInstance().getScene()
					.getSceneMonster(idMonster);
				}
				if (se != null) {
					se.setState(btState);
				}
				 */
			}
		}
	}
	
}