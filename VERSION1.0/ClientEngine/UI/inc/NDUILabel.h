//
//  NDUILabel.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
#ifndef __NDUILabel_H
#define __NDUILabel_H

#include "NDUINode.h"
#include <string>

#include "ccTypes.h"
#include "CCTexture2D.h"

NS_NDENGINE_BGN

//标签的显示方式
typedef enum
{
	LabelTextAlignmentLeft = 0, //左对齐
	LabelTextAlignmentCenter,	//居中
	LabelTextAlignmentRight,	//右对齐
	LabelTextAlignmentHorzCenter,//水平居中
	LabelTextAlignmentVertCenter,//竖直居中
	LabelTextAlignmentLeftCenter    //水平左对齐，垂直居中对齐
}LabelTextAlignment;
	
class NDUILabel : public NDUINode
{
	DECLARE_CLASS(NDUILabel)
	NDUILabel();
	~NDUILabel();
public:
//		
//		函数：SetText
//		作用：设置标签文本内容
//		参数：text文本内容
//		返回值：无
		void SetText(const char* text);
//		
//		函数：GetText
//		作用：获取标签的文本内容
//		参数：无
//		返回值：文本内容
		std::string GetText(){ return m_strText; }
//		
//		函数：SetFontColor
//		作用：设置标签字体的颜色
//		参数：fontColor颜色值rgba
//		返回值：
		void SetFontColor(cocos2d::ccColor4B fontColor);

//		函数：GetFontColor
//		作用：获取标签的字体颜色
//		参数：无
//		返回值：颜色值rgba
		cocos2d::ccColor4B GetFontColor(){ return m_kColor; }
//		
//		函数：SetFontSize
//		作用：设置标签的字体大小
//		参数：fontSize字体大小
//		返回值：无
		void SetFontSize(unsigned int fontSize);
//		
//		函数：GetFontSize
//		作用：获取标签字体大小
//		参数：无
//		返回值：字体大小
		unsigned int GetFontSize(){ return m_uiFontSize; }
//		
//		函数：SetTextAlignment
//		作用：设置标签文本的对齐方式
//		参数：alignment对齐方式
//		返回值：无
		void SetTextAlignment(int alignment);
//		
//		函数：GetTextAlignment
//		作用：获取标签文本的对齐方式
//		参数：无
//		返回值：对齐方式
		int GetTextAlignment(){ return m_eTextAlignment; }
//		
//		函数：SetRenderTimes
//		作用：设置标签内容的渲染次数，注意：渲染次数越高则字体越清晰，但是效率也就越慢，默认渲染2次
//		参数：times渲染次数
//		返回值：无
		void SetRenderTimes(unsigned int times){ m_uiRenderTimes = times; }

//		函数：GetRenderTimes
//		作用：获取标签的渲染次数
//		参数：无
//		返回值：次数
		unsigned int GetRenderTimes(){ return m_uiRenderTimes; }
		
		void SetFontBoderColer(cocos2d::ccColor4B fontColor);
		
		CGSize GetTextureSize() { if (m_texture) return m_texture->getContentSizeInPixels(); return CGSizeZero; }
		void SetHasFontBoderColor(bool bIsBorder){m_bHasFontBoderColor = bIsBorder;};
	public:
		void draw(); override		
		void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
		
	private:
	void preDraw();
	void postDraw();
	void debugDraw();
		void MakeTexture();
		void MakeCoordinates();
		void MakeVertices();
		
	private:
		std::string m_strText;
		cocos2d::ccColor4B m_kColor;
		unsigned int m_uiFontSize;
		unsigned int m_uiRenderTimes;
		LabelTextAlignment m_eTextAlignment;
		CGRect m_kCutRect;
		
		bool m_bNeedMakeTex;
		bool m_bNeedMakeCoo;
		bool m_bNeedMakeVer;
		
		bool m_bHasFontBoderColor;
		cocos2d::ccColor4B m_kColorFontBoder;
		
		cocos2d::CCTexture2D* m_texture;
		GLfloat m_pfVertices[12];
		GLfloat m_pfVerticesBoder[12];
		GLfloat m_pfCoordinates[8];
		GLbyte m_pbColors[16];
		CCRect m_cutRect;
		GLbyte m_pbColorsBorder[16];
};

NS_NDENGINE_END

#endif
