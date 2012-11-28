/*
 *  SocialElement.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SOCIAL_ELEMENT_H__
#define __SOCIAL_ELEMENT_H__

#include "define.h"
#include "NDUILayer.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUIImage.h"
#include "NDManualRole.h"
#include "NDNpc.h"
#include "NDCommonControl.h"
#include "NDScrollLayer.h"
#include "NDUIItemButton.h"

using namespace NDEngine;

// end of zero
void SendSocialRequest(int iUserID, ...);

void RequsetFriendInfo();

void RequestTutorInfo();

void RequestTutorAndFriendInfo();

// static const string STRING_ONLINE = NDCommonCString("online");
// static const string STRING_OFFLINE = NDCommonCString("NotOnline");

enum ELEMENT_STATE {
	ES_OFFLINE = 0,
	ES_ONLINE = 1,
};

class SocialElement
{
public:
	SocialElement() {
		m_id = 0;
		m_param = 0;
		m_state = ES_ONLINE; // 默认在线
	}
	
	~SocialElement() {
		
	}
	
	int m_id;
	int m_param;
	ELEMENT_STATE m_state;
	string m_text1;
	string m_text2;
	string m_text3;
};

typedef vector<SocialElement*> VEC_SOCIAL_ELEMENT;
typedef VEC_SOCIAL_ELEMENT::iterator VEC_SOCIAL_ELEMENT_IT;

typedef struct _tagSocialData
{
	int iId,lvl,lookface;
	std::string sex;
	std::string SynName;
	std::string rank;
	std::string junxian;
	
	std::vector<int> equips;
	
	_tagSocialData() { iId = lvl = lookface = 0; }
}SocialData;

typedef std::map<int, SocialData> map_social_data;
typedef map_social_data::iterator map_social_data_it;

class ManualRoleNode;

#pragma mark 社交头像

class SocialFigure : 
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SocialFigure)
	
	SocialFigure();
	
	~SocialFigure();

public:
	void Initialization(bool showTutor, bool showOnline=true, CCSize size=CCSizeMake(178, 112)); override

	void ChangeFigure(SocialElement* se);
	
	void UpdateFigure();
	
	void ShowLevel(bool show, int lvl);
	
	void SetDefaultFigure(NDPicture* pic);
	
	void SetDefaultLookFace(int lookface);
	
	void SetLookFace(int lookface);
	
	void draw();
	
	void SetVisible(bool visible); override
	
	void OnButtonClick(NDUIButton* button); override
private:
	
	SocialElement		*m_curSe;
	
	NDUIButton			*m_btnEquip, *m_btnLvl;
	
	NDUINode			*m_roleCotainer;
	
	NDManualRole		*m_role;
	
	NDNpc				*m_npc;
	
	NDUIImage			*m_imageRole;
	
	NDUILabel			*m_lbName, *m_lbOnline, *m_lbTutor;
	bool				m_showLvl;
};

#pragma mark 社交信息显示

class SocialEleInfo : 
public NDUILayer
{
	DECLARE_CLASS(SocialEleInfo)
	
	SocialEleInfo();
	
	~SocialEleInfo();
	
public: 
	void Initialization(CCRect rect); override
	
	void ChaneSocialEle(SocialElement* se);
	
	void SetText(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
private:
	NDUIContainerScrollLayer *m_layerScroll;
};


#pragma mark 社交cell

class NDSocialCell : public NDPropCell
{
	DECLARE_CLASS(NDSocialCell)
	
	NDSocialCell();
	
	~NDSocialCell();
	
public:
	void Initialization(); hide
	
	void draw(); override
	
	void ChangeSocialElement(SocialElement* se);
	
	SocialElement* GetSocialElement();
private:
	
	NDPicture *m_picOnline, *m_picOffline;
	
	SocialElement *m_curSe;
};

#pragma mark 查看玩家装备

class SocialPlayerEquip :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SocialPlayerEquip)
	
	SocialPlayerEquip();
	
	~SocialPlayerEquip();
	
public:
	void Initialization(int lookface); override
	void OnButtonClick(NDUIButton* button); override
	void draw(); override
private:
	void ShowEquip(Item* equip);
	void UpdateEquipList();
	void InitEquipItemList(int iEquipPos, Item* item);
	int GetIconIndexByEquipPos(int pos);
private:
	
	NDUILayer	*m_layerEquipInfo, *m_layerEquip;
	
	NDUIContainerScrollLayer *m_layerScroll;
	
	NDUIItemButton	*m_cellinfoEquip[Item::eEP_End];
	
	NDUINode			*m_roleCotainer;
	
	NDManualRole		*m_role;
	
	NDPicture		*m_picRoleBackground;
};

#endif