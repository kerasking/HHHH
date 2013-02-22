/*
 *  NDControlHelp.cpp
 *  DragonDrive
 *
 *  Created by zhangwq 2013.01.29
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDControlHelp.h"



void CtrolBase::Init(UIINFO& info, CCSize& sizeOffset)
{
	m_info = info;

	m_sizeOffset = sizeOffset;
}

CCRect CtrolBase::GetFrameRect()
{
	CCRect rect = CCRectZero;

	rect.origin = ccpAdd(
		m_info.CtrlPos, 
		ccp(m_sizeOffset.width, m_sizeOffset.height));

	if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
	{
		rect.size = CCSizeMake(m_info.nCtrlWidth, m_info.nCtrlHeight);
		return rect;
	}

	if (m_info.strNormalFile.empty()) 
	{
		NDAsssert(0);

		return rect;
	}

	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
		NDPath::GetUIImgPath(m_info.strNormalFile.c_str()) );

	rect.size = pic->GetSize();

	SAFE_DELETE( pic );

	return rect;
}

LabelTextAlignment CtrolBase::GetTextAlign()
{
	/*
	"左对齐";
	"右对齐";
	"水平居中"
	"竖直居中"
	"居中"
	*/

	LabelTextAlignment align = LabelTextAlignmentLeft;
	CCLog("test %s", m_info.strTextAlign.c_str());

	if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("LeftAlign").c_str()) == 0) //左对齐
		align = LabelTextAlignmentLeft;

	else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("RightAlign").c_str()) == 0) //右对齐
		align = LabelTextAlignmentRight;

	else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("HorzCenterAlign").c_str()) == 0) //水平居中对齐
		align = LabelTextAlignmentHorzCenter;

	else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("VertCenterAlign").c_str()) == 0) //竖直居中对齐
		align = LabelTextAlignmentVertCenter;

	else if (stricmp( m_info.strTextAlign.c_str(), GetTxtPri("CenterAlign").c_str()) == 0) //居中对齐
		align = LabelTextAlignmentCenter;

	return align;
}

NDPicture* CtrolBase::GetPicture(std::string& filename, CTRL_UV& uv)
{
	NDPicture* res = NULL;

	if (filename.empty())
	{
		return res;
	}

	if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
	{ 
		// 拉伸 (拉伸后不进行u,v处理)
		// 获取图片大小并与u,v比较,大小不一样说明是抠图,则不做拉伸,这一步以后可以放到UI编辑器(直接导出该信息)
		const string strTemp = NDPath::GetUIImgPath(filename.c_str());
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(strTemp.c_str());

		if (pic)
		{
			CCSize size = pic->GetSize();
			if (uv.w <= int(size.width) && uv.h <= int(size.height))
			{
				pic->Cut(CCRectMake(uv.x, uv.y, uv.w, uv.h ) );

				return pic;
			}
		}

		res  = NDPicturePool::DefaultPool()->AddPicture(
									NDPath::GetUIImgPath(filename.c_str()),
									m_info.nCtrlWidth, m_info.nCtrlHeight );
								
		SAFE_DELETE( pic );
	}
	else
	{ 
		// 不拉伸 (扣出来的图不做拉伸处理)
		res  = NDPicturePool::DefaultPool()->AddPicture( NDPath::GetUIImgPath(filename.c_str()) );

		if (uv.w != 0 && uv.h != 0)
		{
			res->Cut(CCRectMake( uv.x, uv.y, uv.w, uv.h ));
		}
	}

	return res;
}