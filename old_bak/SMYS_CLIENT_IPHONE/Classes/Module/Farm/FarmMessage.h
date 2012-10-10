/*
 *  FarmMessage.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FARM_MESSAGE_H_
#define _FARM_MESSAGE_H_

#include "NDScene.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
#include "NDUIMenuLayer.h"
#include "NDUICustomView.h"

using namespace NDEngine;

#define DECLARE_SCENE(class)		\
public:								\
static class* Scene();

#define IMPLEMENT_SCENE(class)		\
class* class::Scene(){				\
class* scene = new class;			\
scene->Initialization();			\
return scene;						\
}

class FarmMsgListScene;

enum
{
	FarmMessage_Begin = 1,
	FarmMessage_Visit = FarmMessage_Begin,			//访问记录
	FarmMessage_Steal,								//偷盗记录
	FarmMessage_User,								//别人留言
	FarmMessage_Self,								//自己留言
	FarmMessage_End,
};

FarmMsgListScene* QueryFarmMsgListScene(int iType);
FarmMsgListScene* CreateFarmMsgListScene(int iType);

///////////////////////////////////////////////

class FarmMsgListScene :
public NDScene,
public NDUIButtonDelegate
{
	DECLARE_CLASS(FarmMsgListScene)
	
public:
	FarmMsgListScene();
	~FarmMsgListScene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button);
	
	int GetCurPage();
	
	void setCurPage(int iPage);

	void setSumPage(int iPage);
	
	void ClearList();
	
	void AppendRecord(int iRecordID, std::string text);
	
	void DelRecord(int iRecordID);
	
	void SetFarmID(int iFarmID);
	
	void SetType(int iType);
	
	int GetType();
	
	void UpdateTitle();
protected:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id); 
	void queryPage(int page);
protected:
	NDUIMenuLayer *m_menulayerBG;

	NDUITableLayer *m_tlMain, *m_tlOperate;
	int m_iFarmID, m_iType;
	
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbTitle, *m_lbPage;
	
	int m_iCurPage, m_iTotalPage;
	
	std::string m_title;
};
///////////////////////////////////////////////
class FarmMsgVisit :
public FarmMsgListScene
{
	DECLARE_CLASS(FarmMsgVisit)
	DECLARE_SCENE(FarmMsgVisit)
public:
	FarmMsgVisit();
	~FarmMsgVisit();
	
	void Initialization(); override
	
	static FarmMsgVisit* GetInstance();
private:
	static FarmMsgVisit* s_instance;
};
///////////////////////////////////////////////
class FarmMsgSteal :
public FarmMsgListScene
{
	DECLARE_CLASS(FarmMsgSteal)
	DECLARE_SCENE(FarmMsgSteal)
public:
	FarmMsgSteal();
	~FarmMsgSteal();
	
	void Initialization(); override
	
	static FarmMsgSteal* GetInstance();
private:
	static FarmMsgSteal* s_instance;
};
///////////////////////////////////////////////
class FarmMsgSelf :
public FarmMsgListScene,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(FarmMsgSelf)
	DECLARE_SCENE(FarmMsgSelf)
public:
	FarmMsgSelf();
	~FarmMsgSelf();
	
	void Initialization(); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
	bool OnCustomViewConfirm(NDUICustomView* customView); override

	static FarmMsgSelf* GetInstance();
private:
	static FarmMsgSelf* s_instance;
};
///////////////////////////////////////////////
class FarmMsgUser :
public FarmMsgSelf
{
	DECLARE_CLASS(FarmMsgUser)
	DECLARE_SCENE(FarmMsgUser)
public:
	FarmMsgUser();
	~FarmMsgUser();
	
	void Initialization(); override
	
	static FarmMsgUser* GetInstance();
private:
	static FarmMsgUser* s_instance;
};


#endif // _FARM_MESSAGE_H_