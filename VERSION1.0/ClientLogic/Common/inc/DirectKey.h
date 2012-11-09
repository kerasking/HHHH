//
//  DirectKey.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __DirectKey_H
#define __DirectKey_H

#include "NDUILayer.h"
#include "NDUIButton.h"
#include "NDTimer.h"
#include "NDScene.h"
#include <vector>
#include <deque>

using namespace NDEngine;

typedef std::vector<CGPoint> dk_vec_pos;
typedef dk_vec_pos::iterator dk_vec_pos_it;

/***
* 临时性注释 郭浩
* begin
*/
// class NDUIDirectKeyTop : public NDUILayer, public NDNodeDelegate
// {
// 	DECLARE_CLASS(NDUIDirectKeyTop)
// 	
// public:
// 	
// 	NDUIDirectKeyTop();
// 	
// 	~NDUIDirectKeyTop();
// 	
// 	void Initialization(NDNode* observer); override
// 	
// 	void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp); override
// 	
// private:
// 	NDNode* m_nodeObserver;
// };
// 
// class DirectKey : public NDUILayer, public NDUIButtonDelegate//, public ITimerCallback
// , public NDNodeDelegate
// {
// 	DECLARE_CLASS(DirectKey)
// 	DirectKey();
// 	~DirectKey();
// 	
// 	typedef enum 
// 	{
// 		KeyDirectNone,
// 		KeyDirectLeft,
// 		KeyDirectRight,
// 		KeyDirectUp,
// 		KeyDirectDown
// 	}KeyDirect;
// 	
// public:
// 	void Initialization(); override;
// 	//void OnButtonDown(NDUIButton* button); override
// 	//void OnButtonUp(NDUIButton* button); override
// 	void OnTouchDown(KeyDirect type);
// 	void OnTouchUp();
// 	
// 	void OnTimer(OBJID tag); override
// 	
// 	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
// 	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
// 	void OnButtonClick(NDUIButton* button);
// 	void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp); override
// 	
// 	//bool GetPosList(dk_vec_pos& vpos); ///< 临时性注释 郭浩
// 	void ClearPosList();
// 	
// 	void ShowFinish(NDScene* scene);
// 	
// 	void OnBattleBegin();
// 	
// 	void OnBattleEnd();
// 	
// 	bool TouchBegin(NDTouch* touch); override
// 	
// 	bool TouchMoved(NDTouch* touch); override
// 	
// 	bool TouchEnd(NDTouch* touch); override
// private:
// 	void ReverseShrinkState();
// 	void RefreshPosition(CGPoint pos);
// 	
// private:
// 	
// 	typedef std::deque<KeyDirect> deque_dir;
// 	typedef deque_dir::iterator deque_dir_it;
// 	
// 	void DealKey(KeyDirect type);
// 	bool CheckCell(int iCellX, int iCellY);
// 	bool NextDir(int iCellX, int iCellY, KeyDirect& dir);
// 	bool CanDiretect(int iCellX, int iCellY, KeyDirect dir);
// 	
// 	// pos 屏幕坐标
// 	KeyDirect GetPointAtDirect(CGPoint pos);
// 	void UpdateDownPicture();
// private:
// 	NDUIButton *m_btnLeft, *m_btnRight, *m_btnUp, *m_btnDown;
// 	NDTimer* m_timer;
// 	KeyDirect m_keyDirect;
// 	
// 	deque_dir m_dequeDir;
// 	
// 	NDUIButton			*m_btnShrink;
// 	NDUIDirectKeyTop	*m_btnLayer;
// 	
// 	NDPicture			*m_picNormal, *m_picDown;
// 	NDPicture			*m_picCenterNormal, *m_picCenterShrink;
// 	bool m_addShrink;
// 	
// 	bool m_touchDown;
// 	
// 	static bool s_shink;
// 	static CGRect s_Rect;
// };
/***
* 临时性注释 郭浩
* end
*/
#endif