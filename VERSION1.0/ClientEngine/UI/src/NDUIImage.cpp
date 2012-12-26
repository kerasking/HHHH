//
//  NDUIImage.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-18.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDUIImage.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIImage, NDUINode)
	
	NDUIImage::NDUIImage()
	{
		INC_NDOBJ_RTCLS
		m_pic = NULL;
		m_combinePic = NULL;
		m_clearPicOnFree = false;
	}
	
	NDUIImage::~NDUIImage()
	{
		DEC_NDOBJ_RTCLS
		if (m_clearPicOnFree) 
		{
			delete m_pic;
			delete m_combinePic;
		}
	}
	
	void NDUIImage::SetPicture(NDPicture* pic, bool clearPicOnFree)
	{
		if (m_clearPicOnFree) 
		{
			delete m_pic;
			delete m_combinePic;
		}
		
		m_combinePic = NULL;
		m_pic = pic;
		m_clearPicOnFree = clearPicOnFree;
	}
	
	void NDUIImage::SetPictureLua(NDPicture* pic)
	{
		this->SetPicture(pic, true);
	}
	
	CCSize NDUIImage::GetPicSize()
	{
		if (!m_pic)
		{
			return CCSizeZero;
		}
		
		return m_pic->GetSize();
	}
	
	void NDUIImage::SetCombinePicture(NDCombinePicture* pic, bool clearPicOnFree/*= false*/)
	{
		if (m_clearPicOnFree) 
		{
			delete m_pic;
			delete m_combinePic;
		}
		
		m_pic = NULL;
		m_combinePic = pic;
		m_clearPicOnFree = clearPicOnFree;
	}
	
	void NDUIImage::draw()
	{
		if (!isDrawEnabled()) return;
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			if (m_pic) m_pic->DrawInRect(this->GetScreenRect());
			//else if (m_combinePic) m_combinePic->DrawInRect(this->GetScreenRect()); ///< 临时性注释 郭浩
		}		

		//使用NDPicture了，这里不需要debugDraw()了.
	}
}