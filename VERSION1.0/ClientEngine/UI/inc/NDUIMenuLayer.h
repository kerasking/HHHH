//
//  NDUIMenuLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef __NDUIMenuLayer_H
#define __NDUIMenuLayer_H

#include "NDUILayer.h"
#include "NDUIButton.h"

#include "CCTexture2D.h"
#include <cocos2d.h>

using namespace cocos2d;

namespace NDEngine
{
	class NDPicture;
	class NDUIMenuLayer : public NDUILayer , public NDNodeDelegate
	{
		DECLARE_CLASS(NDUIMenuLayer)
		NDUIMenuLayer();
		~NDUIMenuLayer();
	public:
		void Initialization(); override

		unsigned int GetTitleHeight();
		unsigned int GetOperationHeight();
		unsigned int GetTextHeight();
		
		void draw(); override
		void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp); override
		
		NDUIButton* GetCancelBtn() const
		{
			return m_btnCancel;
		}
		
		NDUIButton* GetOkBtn() const
		{
			return m_btnOk;
		}
		
		void ShowOkBtn();
	private:
		//CCMutableArray<NDTile*> *m_tiles;
		CCArray *m_tiles;

		NDPicture* m_picCancel;
		NDPicture* m_picOk;
		NDUIButton	   *m_btnCancel;
		NDUIButton	   *m_btnOk;
		void MakeLeftTopTile();
		void MakeRightTopTile();
		void MakeLeftBottomTile();
		void MakeRightBottomTile();
		
		void drawBackground();
		
		void SetFrameRect(CCRect rect){}hide
		
		
	};
}

#endif
