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
	m_kRectLast = CGRectZero;
	m_kSizeMax = CGSizeZero;
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
	
	CGRect rectDraw = CGRectZero;
	
	rectDraw.size = pic->GetSize();
	
	m_kRectLast.origin = rectDraw.origin = caclNext(m_kRectLast.origin,
		aligment, m_kRectLast.size, rectDraw.size);
	
	m_kRectLast.size = rectDraw.size;
	
	m_vecCombinePic.push_back(CombinePicture(pic, aligment, rectDraw));
	
	if (rectDraw.origin.x + rectDraw.size.width > m_kSizeMax.width)
	{
		m_kSizeMax.width = rectDraw.origin.x + rectDraw.size.width;
	}
	
	if (rectDraw.origin.y + rectDraw.size.height > m_kSizeMax.height)
	{
		m_kSizeMax.height = rectDraw.origin.y + rectDraw.size.height;
	}
}

void NDCombinePicture::SetColor(ccColor4B color)
{
	for_vec(m_vecCombinePic, std::vector<CombinePicture>::iterator)
	{
		((*it).pic)->SetColor(color);
	}
}

CGSize NDCombinePicture::GetSize()
{
	return m_kSizeMax;
}

void NDCombinePicture::DrawInRect(CGRect rect)
{
	for_vec(m_vecCombinePic, std::vector<CombinePicture>::iterator)
	{
		CGRect drawRect = (*it).rectDraw;
		
		drawRect.origin = ccpAdd(drawRect.origin, rect.origin);
		
		((*it).pic)->DrawInRect(drawRect);
	}
}

CGPoint NDCombinePicture::caclNext(CGPoint origin,
								   CombintPictureAligment aligment,
								   CGSize originSize, CGSize selfSize)
{
	CGPoint res = origin;
	
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