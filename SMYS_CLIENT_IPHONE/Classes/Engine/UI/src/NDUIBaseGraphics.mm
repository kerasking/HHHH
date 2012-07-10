//
//  NDUIBaseGraphics.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDUIBaseGraphics.h"
#import "NDUtility.h"
#import "CGPointExtension.h"


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUILine, NDUINode)
	NDUILine::NDUILine()
	{
		m_from = CGPointZero;
		m_to = CGPointZero;
		m_color = ccc4(255, 255, 255, 255);
		m_lineWidth = 0;
	}
	
	NDUILine::~NDUILine()
	{
	}
	
	void NDUILine::draw()
	{
		NDUINode::draw();
		if (this->IsVisibled()) 
		{
			CGRect rect = GetFrameRect();
			if ( int(rect.origin.x) == 0 && int(rect.origin.y) == 0 ) 
			{
				DrawLine(this->m_from, this->m_to, this->m_color, this->m_lineWidth);
			}
			else
			{
				CGRect screenRect = GetScreenRect();
				DrawLine(CGPointMake(m_from.x+screenRect.origin.x, m_from.y+screenRect.origin.y),
							   CGPointMake(m_to.x+screenRect.origin.x, m_to.y+screenRect.origin.y),
							   m_color,
							   m_lineWidth);
			}
			
		}		
	}
	
	//////////////////////////
	IMPLEMENT_CLASS(NDUIPolygon, NDUINode)
	NDUIPolygon::NDUIPolygon()
	{
		m_color = ccc4(0, 0, 0, 0);
		m_lineWidth = 0;
	}
	
	NDUIPolygon::~NDUIPolygon()
	{
	}
	
	void NDUIPolygon::draw()
	{
		NDUINode::draw();
		if (this->IsVisibled()) 
		{
			CGRect rect = this->GetScreenRect();
			DrawPolygon(rect, m_color, m_lineWidth);
		}
		
	}
	
	//////////////////////////
	IMPLEMENT_CLASS(NDUIRecttangle, NDUINode)
	NDUIRecttangle::NDUIRecttangle()
	{
		m_color = ccc4(0, 0, 0, 0);
	}
	
	NDUIRecttangle::~NDUIRecttangle()
	{
		
	}
	
	void NDUIRecttangle::draw()
	{
		NDUINode::draw();
		if (this->IsVisibled()) 
		{
			CGRect rect = this->GetScreenRect();
			DrawRecttangle(rect, m_color);
		}
		
	}
	
	//////////////////////////
	IMPLEMENT_CLASS(NDUICircleRect, NDUINode)
	NDUICircleRect::NDUICircleRect()
	{
		m_colorFrame = ccc4(0, 0, 0, 0);
		m_colorFill = ccc4(0, 0, 0, 0);
		m_bFill = false;
		m_bFrame = false;
		m_uiRadius = 1;
	}
	
	NDUICircleRect::~NDUICircleRect()
	{
	}
	
	void NDUICircleRect::SetRadius(unsigned int radius)
	{
		//CGRect rect = this->GetFrameRect();
//		if (rect.size.width < 2 * radius || rect.size.height < 2 *radius)
//		{
//			return;
//		}
		m_uiRadius = radius;
	}
	// 设置边框颜色,如果设置了填充颜色,该设置失效
	void NDUICircleRect::SetFrameColor(ccColor4B color)
	{
		m_colorFrame = color;
		m_bFrame = true;
	}
	// 设置填充颜色
	void NDUICircleRect::SetFillColor(ccColor4B color)
	{
		m_colorFill = color;
		m_bFill = true;
	}
	
	void NDUICircleRect::draw()
	{
		NDUINode::draw();
		if (this->IsVisibled() && m_bFill && m_uiRadius >= 1) 
		{
			CGRect rect = this->GetScreenRect();
			if (rect.size.width < 2 * m_uiRadius || rect.size.height < 2 *m_uiRadius)
			{
				return;
			}
			
			if (m_bFrame) 
			{
				DrawCircle(ccp(rect.origin.x+m_uiRadius-1, rect.origin.y+m_uiRadius-1),
						   m_uiRadius, 0, 10, m_colorFrame);
				DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius+1, rect.origin.y+m_uiRadius-1),
						   m_uiRadius, 0, 10, m_colorFrame);
				DrawCircle(ccp(rect.origin.x+m_uiRadius-1, rect.origin.y+rect.size.height-m_uiRadius+1),
						   m_uiRadius, 0, 10, m_colorFrame);
				DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius+1, rect.origin.y+rect.size.height-m_uiRadius+1),
						   m_uiRadius, 0, 10, m_colorFrame);
				
				DrawRecttangle(CGRectMake(rect.origin.x+m_uiRadius-1, rect.origin.y-1, rect.size.width-2*m_uiRadius+2, rect.size.height+2), m_colorFrame);
				DrawRecttangle(CGRectMake(rect.origin.x-1, rect.origin.y+m_uiRadius-1, rect.size.width+2, rect.size.height-2*m_uiRadius+2), m_colorFrame);
			}
			
			DrawCircle(ccp(rect.origin.x+m_uiRadius, rect.origin.y+m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius, rect.origin.y+m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+m_uiRadius, rect.origin.y+rect.size.height-m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius, rect.origin.y+rect.size.height-m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
					   
			DrawRecttangle(CGRectMake(rect.origin.x+m_uiRadius, rect.origin.y, rect.size.width-2*m_uiRadius, rect.size.height), m_colorFill);
			DrawRecttangle(CGRectMake(rect.origin.x, rect.origin.y+m_uiRadius, rect.size.width, rect.size.height-2*m_uiRadius), m_colorFill);
		}
	}
	
	//////////////////////////
	IMPLEMENT_CLASS(NDUITriangle, NDUINode)

	NDUITriangle::NDUITriangle()
	{
		m_color = ccc4(255, 255, 255, 255);
		for (int i = 0; i < 3; i++) 
		{
			m_pos[i] = CGPointZero;
		}
		
		m_needRecacul = false;
	}
	
	NDUITriangle::~NDUITriangle()
	{
	}
	
	void NDUITriangle::SetColor(ccColor4B color)
	{
		m_color = color;
	}
	
	void NDUITriangle::SetPoints(CGPoint first, CGPoint second, CGPoint third)
	{
		m_pos[0] = first;
		m_pos[1] = second;
		m_pos[2] = third;
		
		m_needRecacul = true;
	}
	
	void NDUITriangle::draw()
	{
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			CGPoint origin = this->GetScreenRect().origin;
			
			DrawTriangle(ccpAdd(origin, m_pos[0]), 
						 ccpAdd(origin, m_pos[1]), 
						 ccpAdd(origin, m_pos[2]), 
						 m_color);
		}
	}
	
	void NDUITriangle::recacul()
	{
		/*
		this->SetFrameRect(CGRectZero);
		CGRect scrRect = this->GetScreenRect();
		
		int iXMin = m_pos[0].x, iXMax = m_pos[0].x, iYMin = m_pos[0].y, iYMax = m_pos[0].y;
		
		for (int i = 1; i < 3; i++) 
		{
			iXMin = MIN(iXMin, m_pos[i].x);	
			iXMax = MAX(iXMax, m_pos[i].x);
			iYMin = MIN(iYMin, m_pos[i].y);
			iYMax = MAX(iYMax, m_pos[i].y);			
		}
		
		this->SetFrameRect(CGRectMake(iXMin, iYMin, iXMax-iXMin, iYMax-iYMin));
		
		for (int i = 0; i < 3; i++) 
		{
			m_pos[i] = ccp(scrRect.origin.x+m_pos[i].x, scrRect.origin.y+m_pos[i].y);
		}
		*/
	}
}
