//
//  NDUIBaseGraphics.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//	介绍
//	基础图形节点
#ifndef __NDUIBaseGraphics_H
#define __NDUIBaseGraphics_H

#include "NDUINode.h"

namespace NDEngine
{
	class NDUILine : public NDUINode
	{
		DECLARE_CLASS(NDUILine)
		NDUILine();
		~NDUILine();
	public:
		void SetWidth(unsigned int lineWidth){ m_lineWidth = lineWidth; }
		void SetColor(ccColor3B color){ m_color = ccc4(color.r, color.g, color.b, 255); }
		void SetFromPoint(CGPoint from){ m_from = from; }
		void SetToPoint(CGPoint to){ m_to = to; }
	public:
		void draw();
		
	private:
		unsigned int m_lineWidth;
		ccColor4B m_color;
		CGPoint m_from, m_to;
	};
	
	class NDUIPolygon : public NDUINode
	{
		DECLARE_CLASS(NDUIPolygon)
		NDUIPolygon();
		~NDUIPolygon();
	public:
		void SetLineWidth(unsigned int lineWidth){ m_lineWidth = lineWidth; }
		void SetColor(ccColor3B color){ m_color = ccc4(color.r, color.g, color.b, 255); }
	public:
		void draw();
		
	private:
		unsigned int m_lineWidth;
		ccColor4B m_color;
	};
	
	class NDUIRecttangle: public NDUINode
	{
		DECLARE_CLASS(NDUIRecttangle)
		NDUIRecttangle();
		~NDUIRecttangle();
	public:
		void SetColor(ccColor4B color){  m_color = ccc4(color.r, color.g, color.b, color.a); }
	public:
		void draw();
		
	private:
		ccColor4B m_color;
	};
	
	class NDUICircleRect : public NDUINode
	{
		DECLARE_CLASS(NDUICircleRect)
	public:
		NDUICircleRect();
		~NDUICircleRect();

		void SetRadius(unsigned int radius);
		// 设置边框颜色
		void SetFrameColor(ccColor4B color);
		// 设置填充颜色
		void SetFillColor(ccColor4B color);
		
		void draw();
	private:
		ccColor4B m_colorFrame; 
		ccColor4B m_colorFill; 
		bool m_bFill, m_bFrame;
		unsigned int m_uiRadius;
	};
	
	class NDUITriangle : public NDUINode
	{
		DECLARE_CLASS(NDUITriangle)
	public:
		NDUITriangle();
		~NDUITriangle();

		void SetColor(ccColor4B color);
		
		void SetPoints(CGPoint first, CGPoint second, CGPoint third);
		
		void draw();
	private:
		void recacul();
	private:
		ccColor4B m_color;
		CGPoint m_pos[3];
		bool m_needRecacul;
	};
}
#endif
