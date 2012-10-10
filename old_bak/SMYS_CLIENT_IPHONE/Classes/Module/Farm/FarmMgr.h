/*
 *  FarmMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FARM_MGR_H_
#define _FARM_MGR_H_
#include "Singleton.h"
#include "define.h"
#include <vector>
#include <string>
#include <map>
#include "NDNetMsg.h"
#include "NDUIDialog.h"

using namespace std;

#define NDFarmMgrObj	NDEngine::NDFarmMgr::GetSingleton()
#define NDFarmMgrPtr	NDEngine::NDFarmMgr::GetSingletonPtr()

typedef struct FARM_BUILDING_INFO{
	unsigned int idNpc;
	unsigned int lookface;
	int upLevel;
	std::string name;
	FARM_BUILDING_INFO(unsigned int _idNpc, unsigned int _lookface, unsigned char _upLevel, std::string name)
	{
		idNpc = _idNpc;
		lookface = _lookface;
		upLevel = _upLevel;
		this->name = name;
	}
}FarmBuildingInfo;

typedef struct FARM_INFO{
	unsigned int idNpc;
	unsigned int lookface; 
	std::string name;
	FARM_INFO(unsigned int _idNpc, unsigned int _lookface, const std::string& _name)
	{
		idNpc = _idNpc;
		lookface = _lookface;
		name = _name;
	}
}FarmInfo;

typedef struct _tagFarmMuChangOpt 
{
	int iFarmID, iEntity, iDlg;
	
	struct opt
	{
		int iID, iAction;
		opt() { memset(this, 0, sizeof(*this)); }
	};
	
	_tagFarmMuChangOpt()
	{
		iFarmID = 0; iEntity = 0; iDlg = -1;
	}
	
	std::vector<opt> opts;
}FarmMuChangOpt;

typedef struct _tagFarmStatusData
{
	std::string title;
	int total, left;
	bool bNew;
	_tagFarmStatusData(){
		total = left = 0; bNew = false;
	};
}FarmStatusData;

namespace NDEngine
{
	struct HamletInfo {
		int idHamlet;
		int nNum;
		std::string name;
		int idNPc;
	};
	
	class NDFarmMgr :
	public TSingleton<NDFarmMgr>,
	public NDMsgObject,
	public NDObject,
	public NDUIDialogDelegate
	{
		DECLARE_CLASS(NDFarmMgr)
	public:
		NDFarmMgr();
		~NDFarmMgr();
		
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
		
		/*处理感兴趣的网络消息*/
		bool process(MSGID msgID, NDTransData* data, int len); override
		
		void processFarmStorage(NDTransData& data);
		
		void processStorageAccess(NDTransData& data); 
		
		void processHamlet(NDTransData& data); 
		
		void processEnterHamlet(NDTransData& data); 
		
		void processFarmList(NDTransData& data); 
		
		void processFarmProduce(NDTransData& data);
		
		void processFarmTrends(NDTransData& data);
		
		void processFarmHarvest(NDTransData& data);
		
		void processFarmTimeCount(NDTransData& data);
		
		void processFarmMessageList(NDTransData& data);
		
		void processFarmQueryMessage(NDTransData& data);
		
		void processFarmLeaveMessage(NDTransData& data);
		
		void processFarmMuChangOpt(NDTransData& data);
		
		void processFarmMuChang(NDTransData& data);
		
		void processFarmMuChangProdOpt(NDTransData& data);
		
		void processUpdateFarmTrends(NDTransData& data);
		
		void processUpdateMapName(NDTransData& data);
		
		void processMoveFarmLand(NDTransData& data);
		
		void processMoveFarmLandNpcList(NDTransData& data); 
		
		std::vector<HamletInfo> m_vecHamletInfo; // 村落
		std::vector<HamletInfo> m_vecEmptyHamletInfo; // 空地列表
	
		FarmStatusData fs;
		
	private:
		std::vector<FarmBuildingInfo> m_buildings;
		std::vector<FarmInfo> m_farms;
		
		FarmMuChangOpt muchangOpt;
		
	private:
		void UpdateNpcLookface(unsigned int idNpc, unsigned int newLookface);
		void DealWithBuildingInfos();
		void DealWithFarmInfos();
	};
	
	
	/////////////////////////////////////////////////////
	void showUseItemUI(int npcId,int type);
}

#endif // _FARM_MGR_H_