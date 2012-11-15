#ifndef __NDUILabel_H
#define __NDUILabel_H

#include "NDUINode.h"
#include <string>

#import "ccTypes.h"
#import "CCTexture2D.h"

namespace NDEngine
{	
	//标签的显示方式
	typedef enum
	{
		LabelTextAlignmentLeft = 0, //左对齐
		LabelTextAlignmentCenter,	//居中
		LabelTextAlignmentRight		//右对齐
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
		std::string GetText(){ return m_text; }
//		
//		函数：SetFontColor
//		作用：设置标签字体的颜色
//		参数：fontColor颜色值rgba
//		返回值：
		void SetFontColor(ccColor4B fontColor);
//		
//		函数：GetFontColor
//		作用：获取标签的字体颜色
//		参数：无
//		返回值：颜色值rgba
		ccColor4B GetFontColor(){ return m_color; }
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
		unsigned int GetFontSize(){ return m_fontSize; }
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
		int GetTextAlignment(){ return m_textAlignment; }
//		
//		函数：SetRenderTimes
//		作用：设置标签内容的渲染次数，注意：渲染次数越高则字体越清晰，但是效率也就越慢，默认渲染2次
//		参数：times渲染次数
//		返回值：无
		void SetRenderTimes(unsigned int times){ m_renderTimes = times; }
//		
//		函数：GetRenderTimes
//		作用：获取标签的渲染次数
//		参数：无
//		返回值：次数
		unsigned int GetRenderTimes(){ return m_renderTimes; }
		
		void SetFontBoderColer(ccColor4B fontColor);
		
		CCSize GetTextureSize() { if (m_texture) return m_texture.contentSizeInPixels; return CCSizeZero; }
	public:
		void draw(); override		
		void OnFrameRectChange(CCRect srcRect, CCRect dstRect); override
		
	private:
		void MakeTexture();
		void MakeCoordinates();
		void MakeVertices();
		
	private:
		std::string m_text;
		ccColor4B m_color;
		unsigned int m_fontSize;
		unsigned int m_renderTimes;
		LabelTextAlignment m_textAlignment;
		CCRect m_cutRect;
		
		bool m_needMakeTex, m_needMakeCoo, m_needMakeVer;
		
		bool m_hasFontBoderColor;
		ccColor4B m_colorFontBoder;
		
		CCTexture2D *m_texture;
		GLfloat m_vertices[12], m_verticesBoder[12];
		GLfloat m_coordinates[8];
		GLbyte m_colors[16], m_colorsBorder[16];
	};
}

#endif


