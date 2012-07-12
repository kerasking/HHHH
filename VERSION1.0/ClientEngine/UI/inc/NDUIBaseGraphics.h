//
//  NDUIBaseGraphics.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-13.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//
//	介绍
//	基础图形节点
#ifndef __NDUIBaseGraphics_H
#define __NDUIBaseGraphics_H

#include "NDUINode.h"

namespace NDEngine
{
	//opengl绘图函数；必须在draw方法里调用，否则将不会长久生效
	//画矩形
	void DrawRecttangle(CGRect rect, cocos2d::ccColor4B color);
	//画多边形
	void DrawPolygon(CGRect rect, cocos2d::ccColor4B color, GLuint lineWidth);
	//画线
	void DrawLine(CGPoint fromPoint, CGPoint toPoint, cocos2d::ccColor4B color, GLuint lineWidth);
	//画圆
	void DrawCircle(CGPoint center, float r, float a, int segs, cocos2d::ccColor4B color);
	// 画边框
	void DrawFrame(int borderColor, int x, int y, int width, int height);
	// 画三角形
	void DrawTriangle(CGPoint first, CGPoint second, CGPoint third, cocos2d::ccColor4B color);

	class NDUILine : public NDUINode
	{
		DECLARE_CLASS(NDUILine)
		NDUILine();
		~NDUILine();
	public:
		void SetWidth(unsigned int lineWidth){ m_lineWidth = lineWidth; }
		void SetColor(cocos2d::ccColor3B color){ m_color = ccc4(color.r, color.g, color.b, 255); }
		void SetFromPoint(CGPoint from){ m_from = from; }
		void SetToPoint(CGPoint to){ m_to = to; }
	public:
		void draw();
		
	private:
		unsigned int m_lineWidth;
		cocos2d::ccColor4B m_color;
		CGPoint m_from, m_to;
	};
	
	class NDUIPolygon : public NDUINode
	{
		DECLARE_CLASS(NDUIPolygon)
		NDUIPolygon();
		~NDUIPolygon();
	public:
		void SetLineWidth(unsigned int lineWidth){ m_lineWidth = lineWidth; }
		void SetColor(cocos2d::ccColor3B color){ m_color = ccc4(color.r, color.g, color.b, 255); }
	public:
		void draw();
		
	private:
		unsigned int m_lineWidth;
		cocos2d::ccColor4B m_color;
	};
	
	class NDUIRecttangle: public NDUINode
	{
		DECLARE_CLASS(NDUIRecttangle)
		NDUIRecttangle();
		~NDUIRecttangle();
	public:
		void SetColor(cocos2d::ccColor4B color){  m_color = ccc4(color.r, color.g, color.b, color.a); }
	public:
		void draw();
		
	private:
		cocos2d::ccColor4B m_color;
	};
	
	class NDUICircleRect : public NDUINode
	{
		DECLARE_CLASS(NDUICircleRect)
	public:
		NDUICircleRect();
		~NDUICircleRect();

		void SetRadius(unsigned int radius);
		// 设置边框颜色
		void SetFrameColor(cocos2d::ccColor4B color);
		// 设置填充颜色
		void SetFillColor(cocos2d::ccColor4B color);
		
		void draw();
	private:
		cocos2d::ccColor4B m_colorFrame; 
		cocos2d::ccColor4B m_colorFill; 
		bool m_bFill, m_bFrame;
		unsigned int m_uiRadius;
	};
	
	class NDUITriangle : public NDUINode
	{
		DECLARE_CLASS(NDUITriangle)
	public:
		NDUITriangle();
		~NDUITriangle();

		void SetColor(cocos2d::ccColor4B color);
		
		void SetPoints(CGPoint first, CGPoint second, CGPoint third);
		
		void draw();
	private:
		void recacul();
	private:
		cocos2d::ccColor4B m_color;
		CGPoint m_pos[3];
		bool m_needRecacul;
	};
}
#endif
