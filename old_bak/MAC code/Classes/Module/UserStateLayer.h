/*
 *  UserStateLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_USER_STATE_LAYER_H__
#define __ND_USER_STATE_LAYER_H__

#include "define.h"
#include "NDLayer.h"
#include "GameScene.h"
#include "NDPlayer.h"

using namespace NDEngine;

struct PosText
{
	PosText(int idPosText, int dir, int posX, int posY, int showSec, int clrIndex, int num, string& str, int clrBackIndex=-1);
	~PosText();
	
	bool OnTimer();
	
	int m_id;
	int m_dir;
	int m_posX;
	int m_posY;
	int m_showSec;
	ccColor4B m_clr;
	int m_num;
	string m_str;
	
	bool m_bConstant;
	bool m_bShowBackColor;
	ccColor4B m_clrBack;
	
private:
	bool pharsePosTextColor(int clrIndex, ccColor4B& color);
};

class UserStateLayer :
public NDLayer
{
	DECLARE_CLASS(UserStateLayer)
public:
	UserStateLayer();
	~UserStateLayer();
	
	void Initialization();
	
	void AddStateLabel(int idState, string& str);
	void RemoveStateLabel(int idState);
	
	void AddPosText(PosText* pt);
	void RemovePosText(PosText* pt);
	
	void draw();
	
private:
	typedef map<int, NDUILabel*> MAP_STATE_LABEL;
	typedef MAP_STATE_LABEL::iterator MAP_STATE_LABEL_IT;
	
	typedef map<int, vector<NDUILayer*> > MAP_POS_TEXT_LABEL;
	typedef MAP_POS_TEXT_LABEL::iterator MAP_POS_TEXT_LABEL_IT;
	
	MAP_STATE_LABEL m_mapLabel;
	MAP_POS_TEXT_LABEL m_mapPosTextLabel;
};

#endif