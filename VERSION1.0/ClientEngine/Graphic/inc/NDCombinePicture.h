/*
 *  NDCombinePicture.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-5.
 *  Copyright 2011 网龙(DeNA). All rights reserved.
 *
 */

#ifndef _ND_COMBINE_PICTURE_H_
#define _ND_COMBINE_PICTURE_H_

#include "NDPicture.h"
#include <vector>

using namespace NDEngine;

// 简要描述
// 1.拼接N个NDPicture对象
// 2.负责所有NDPicture对象的绘制与释放
// 3.拼接规则:新增加的对象可放在最后一个对象的九个方向位置(包括自己)

typedef enum
{
	// 以加入的最后一个对象为基准,为空时加在原点处
	CombintPictureAligmentBegin			= 0, 
	CombintPictureAligmentSelf			= CombintPictureAligmentBegin,
	CombintPictureAligmentRight,
	CombintPictureAligmentRightDown,
	CombintPictureAligmentDown,
	CombintPictureAligmentLeftDown,
	CombintPictureAligmentLeft,
	CombintPictureAligmentLeftUp,
	CombintPictureAligmentUp,
	CombintPictureAligmentRightUp,
	CombintPictureAligmentEnd,										
}CombintPictureAligment;

class NDCombinePicture : public NDObject
{
	DECLARE_CLASS(NDCombinePicture)

public:
	
	NDCombinePicture();
	
	~NDCombinePicture();
	
	void AddPicture(NDPicture* pic, CombintPictureAligment aligment);
	
	void SetColor(cocos2d::ccColor4B color);
	
	CGSize GetSize();
	
	void DrawInRect(CGRect rect);
	
private:
	
	CGPoint caclNext(CGPoint origin, CombintPictureAligment aligment, CGSize originSize, CGSize selfSize);
	
	void Clear();
	
private:
	
	struct CombinePicture 
	{
		NDPicture* pic;
		
		CombintPictureAligment aligment;
		
		CGRect rectDraw;
		
		CombinePicture(NDPicture* pic, CombintPictureAligment aligment, CGRect rectDraw)
		{
			this->pic = pic;
			
			this->aligment = aligment;
			
			this->rectDraw = rectDraw;
		}
	};
	
	CGRect m_rectLast;
	
	CGSize m_sizeMax;
	
	std::vector<CombinePicture> m_vecCombinePic;
};

#endif // _ND_COMBINE_PICTURE_H_