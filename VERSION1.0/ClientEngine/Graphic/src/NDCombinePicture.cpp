/*
 *  NDCombinePicture.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-5.
 *  Copyright 2011 ÍøÁú(DeNA). All rights reserved.
 *
 */

#include "NDCombinePicture.h"
#include "platform.h"
#include "CCPointExtension.h"

using namespace cocos2d;


IMPLEMENT_CLASS(NDCombinePicture, NDObject)

NDCombinePicture::NDCombinePicture()
{
	m_kRectLast = CCRectZero;
	m_kSizeMax = CCSizeZero;
}

NDCombinePicture::~NDCombinePicture()
{
	Clear();
}

void NDCombinePicture::AddPicture(NDPicture* pic, CombintPictureAligment aligment)
{
	if (!pic)
	{
		return;
	}
	
	CCRect kDrawRect = CCRectZero;
	
	kDrawRect.size = pic->GetSize();
	
	m_kRectLast.origin = kDrawRect.origin = caclNext(m_kRectLast.origin,
		aligment, m_kRectLast.size, kDrawRect.size);
	
	m_kRectLast.size = kDrawRect.size;
	
	m_vecCombinePic.push_back(CombinePicture(pic, aligment, kDrawRect));
	
	if (kDrawRect.origin.x + kDrawRect.size.width > m_kSizeMax.width)
	{
		m_kSizeMax.width = kDrawRect.origin.x + kDrawRect.size.width;
	}
	
	if (kDrawRect.origin.y + kDrawRect.size.height > m_kSizeMax.height)
	{
		m_kSizeMax.height = kDrawRect.origin.y + kDrawRect.size.height;
	}
}

void NDCombinePicture::SetColor(ccColor4B color)
{
	for_vec(m_vecCombinePic, std::vector<CombinePicture>::iterator)
	{
		((*it).pic)->SetColor(color);
	}
}

CCSize NDCombinePicture::GetSize()
{
	return m_kSizeMax;
}

void NDCombinePicture::DrawInRect(CCRect rect)
{
	for_vec(m_vecCombinePic, std::vector<CombinePicture>::iterator)
	{
		CCRect drawRect = (*it).rectDraw;
		
		drawRect.origin = ccpAdd(drawRect.origin, rect.origin);
		
		((*it).pic)->DrawInRect(drawRect);
	}
}

CCPoint NDCombinePicture::caclNext(CCPoint origin,
								   CombintPictureAligment aligment,
								   CCSize originSize, CCSize selfSize)
{
	CCPoint res = origin;
	
	if (m_vecCombinePic.empty() 
		|| aligment < CombintPictureAligmentBegin 
		|| aligment >= CombintPictureAligmentEnd
		|| aligment == CombintPictureAligmentSelf) 
	{
		return res;
	}
	
	switch (aligment) 
	{
		case CombintPictureAligmentRight:
			res.x += originSize.width;
			break;
		case CombintPictureAligmentRightDown:
			res.x += originSize.width;
			res.y += originSize.height;
			break;
		case CombintPictureAligmentDown:
			res.y += originSize.height;
			break;
		case CombintPictureAligmentLeftDown:
			res.x -= selfSize.width;
			res.y += originSize.height;
			break;
		case CombintPictureAligmentLeft:
			res.x -= selfSize.width;
			break;
		case CombintPictureAligmentLeftUp:
			res.x -= selfSize.width;
			res.y -= selfSize.height;
			break;
		case CombintPictureAligmentUp:
			res.y -= selfSize.height;
			break;
		case CombintPictureAligmentRightUp:
			res.x += originSize.width;
			res.y -= selfSize.height;
			break;
		default:
			break;
	}
	
	return res;
}

void NDCombinePicture::Clear()
{
	for_vec(m_vecCombinePic, std::vector<CombinePicture>::iterator)
	{
		delete (*it).pic;
	}
	
	m_vecCombinePic.clear();
}