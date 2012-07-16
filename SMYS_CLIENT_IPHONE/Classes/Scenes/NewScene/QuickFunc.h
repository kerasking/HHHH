/*
 *  QuickFunc.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _QUICK_FUNC_H_
#define _QUICK_FUNC_H_

#include "NDUISpeedBar.h"
#include "NDUISpecialLayer.h"
#include "NDTip.h"

class QuickFunc : 
public NDUISpeedBar,
public NDUISpeedBarDelegate
{
	DECLARE_CLASS(QuickFunc)
	
public:
	
	QuickFunc();
	
	~QuickFunc();
	
	void Initialization(bool bShrink=false); override
	
	void OnBattleBegin();
	
	void OnNDUISpeedBarEvent(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info, bool focused); override
	
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	bool OnButtonDragOver(NDUIButton* overButton, bool inRange); override
	
	bool OnButtonLongClick(NDUIButton* button); override
	
	bool OnButtonLongTouch(NDUIButton* button); override
	
	void OnButtonDown(NDUIButton* button); override
	
	void OnButtonUp(NDUIButton* button); override
	
	void ShowTaskTip(bool show,std::string tip);
protected:
	void DealFunc(int func);
	
	void Layout(); override
	
	void DrawBackground(); override
	
	void OnDrawAjustUI(); override
	
	void ShowMask(bool show, NDPicture* pic=NULL);
	
	NDPicture* GetPictureByUIKey(int key);
	
	int GetFuncByKey(int key);
private:	
	NDPicture *m_picItem[6];
	
	CAutoLink<NDUIMaskLayer> m_layerMask;
	
	LayerTip* m_taskFinishTip;
};

#endif // _QUICK_FUNC_H_