//
//  NDUIBaseGraphics.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "NDUIBaseGraphics.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "CCDrawingPrimitives.h"

using namespace cocos2d;


namespace NDEngine
{
	void DrawRecttangle(CGRect rect, ccColor4B color)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();

		GLfloat vertices[8] = { 
			rect.origin.x, winSize.height - rect.origin.y - rect.size.height, 
			rect.origin.x + rect.size.width, winSize.height - rect.origin.y - rect.size.height, 
			rect.origin.x, winSize.height - rect.origin.y, 
			rect.origin.x + rect.size.width, winSize.height - rect.origin.y
		};

		GLbyte colors[16] = {
			color.r, color.g, color.b, color.a,
			color.r, color.g, color.b, color.a,
			color.r, color.g, color.b, color.a,
			color.r, color.g, color.b, color.a
		};

		glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
		glVertexPointer(2, GL_FLOAT, 0, vertices);		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	

		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_TEXTURE_2D);	

	}

	void DrawPolygon(CGRect rect, ccColor4B color, GLuint lineWidth)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		float scale		= NDDirector::DefaultDirector()->GetScaleFactor();	

		glLineWidth(lineWidth);
		glColor4ub(color.r, color.g, color.b, color.a); 

		if (CompareEqualFloat(scale, 0.0f))
		{
			CGPoint vertices[4] = {
				ccp(rect.origin.x, winSize.height - rect.origin.y - rect.size.height), 
				ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y - rect.size.height),
				ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y),
				ccp(rect.origin.x, winSize.height - rect.origin.y)			
			}; 
			ccDrawPoly(vertices, 4, true);
		}
		else
		{
			CGPoint vertices[4] = {
				ccp(rect.origin.x / scale, (winSize.height - rect.origin.y - rect.size.height) / scale), 
				ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y - rect.size.height) / scale),
				ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y) / scale),
				ccp(rect.origin.x / scale, (winSize.height - rect.origin.y) / scale)			
			}; 
			ccDrawPoly(vertices, 4, true);
		}

		glColor4ub(255, 255, 255, 255); 
	}

	void DrawLine(CGPoint fromPoint, CGPoint toPoint, ccColor4B color, GLuint lineWidth)
	{	
		CGSize winSize	= NDDirector::DefaultDirector()->GetWinSize();
		float scale		= NDDirector::DefaultDirector()->GetScaleFactor();

		glLineWidth(lineWidth);
		glColor4ub(color.r, color.g, color.b, color.a);

		if (CompareEqualFloat(scale, 0.0f))
		{
			ccDrawLine(ccp(fromPoint.x,winSize.height - fromPoint.y), ccp(toPoint.x, winSize.height - toPoint.y));
		}
		else
		{
			ccDrawLine(ccp(fromPoint.x / scale, (winSize.height - fromPoint.y)  / scale), 
				ccp(toPoint.x / scale, (winSize.height - toPoint.y) / scale));
		}

		glColor4ub(255, 255, 255, 255);
	}

	void DrawCircle(CGPoint center, float r, float a, int segs, ccColor4B color)
	{
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		CGPoint glCenter = ccp(center.x, winSize.height - center.y);

		glColor4ub(color.r, color.g, color.b, color.a);

		int additionalSegment = 1;

		const float coef = 2.0f * (float)M_PI/segs;

		float *vertices = (float *)malloc( sizeof(float)*2*(segs+2));
		if( ! vertices )
			return;

		memset( vertices,0, sizeof(float)*2*(segs+2));

		for(int i=0;i<=segs;i++)
		{
			float rads = i*coef;
			float j = r * cosf(rads + a) + glCenter.x;
			float k = r * sinf(rads + a) + glCenter.y;

			vertices[i*2] = j;
			vertices[i*2+1] =k;
		}
		vertices[(segs+1)*2] = glCenter.x;
		vertices[(segs+1)*2+1] = glCenter.y;

		// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
		// Needed states: GL_VERTEX_ARRAY, 
		// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);

		glVertexPointer(2, GL_FLOAT, 0, vertices);	
		glDrawArrays(GL_TRIANGLE_FAN, 0, segs+additionalSegment);

		// restore default state
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_TEXTURE_2D);	

		free( vertices );

		glColor4ub(255, 255, 255, 255); 
	}

	void DrawFrame(int borderColor, int x, int y, int width, int height) {

		int y2 = y + height - 1, x2 = x + width - 1;

		ccColor4B clr = INTCOLORTOCCC4(borderColor);
		DrawRecttangle(CGRectMake(x - 1, y - 1, 4, 4), clr); // ×óÉÏ½Ç¿ò
		DrawRecttangle(CGRectMake(x2 - 3, y - 1, 4, 4), clr); // ÓÒÉÏ½Ç¿ò

		DrawRecttangle(CGRectMake(x - 1, y2 - 3, 4, 4), clr); // ×óÏÂ½Ç¿ò
		DrawRecttangle(CGRectMake(x2 - 3, y2 - 3, 4, 4), clr); // ÓÒÏÂ½Ç¿ò

		DrawLine(CGPointMake(x, y + 5), CGPointMake(x + 5, y + 5), clr, 1);
		DrawLine(CGPointMake(x + 5, y), CGPointMake(x + 5, y + 5), clr, 1);
		DrawLine(CGPointMake(x2, y + 5), CGPointMake(x2 - 5, y + 5), clr, 1);
		DrawLine(CGPointMake(x2 - 5, y), CGPointMake(x2 - 5, y + 5), clr, 1);

		DrawLine(CGPointMake(x2, y2 - 5), CGPointMake(x2 - 5, y2 - 5), clr, 1);
		DrawLine(CGPointMake(x2 - 5, y2), CGPointMake(x2 - 5, y2 - 5), clr, 1);
		DrawLine(CGPointMake(x, y2 - 5), CGPointMake(x + 5, y2 - 5), clr, 1);
		DrawLine(CGPointMake(x + 5, y2), CGPointMake(x + 5, y2 - 5), clr, 1);

		DrawLine(CGPointMake(x + 5, y), CGPointMake(x + width - 6, y), clr, 1);
		DrawLine(CGPointMake(x + 5, y2), CGPointMake(x + width - 6, y2), clr, 1);

		DrawLine(CGPointMake(x, y + 5), CGPointMake(x, y2 - 5), clr, 1);
		DrawLine(CGPointMake(x2, y + 5), CGPointMake(x2, y2 - 5), clr, 1);
	}

	void DrawTriangle(CGPoint first, CGPoint second, CGPoint third, ccColor4B color)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		CGSize winSize = NDEngine::NDDirector::DefaultDirector()->GetWinSize();

		GLfloat vertices[6] = { 
			first.x, winSize.height - first.y, 
			second.x, winSize.height - second.y, 
			third.x, winSize.height - third.y
		};

		GLbyte colors[12] = {
			color.r, color.g, color.b, color.a,
			color.r, color.g, color.b, color.a,
			color.r, color.g, color.b, color.a,
		};

		glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
		glVertexPointer(2, GL_FLOAT, 0, vertices);		
		glDrawArrays(GL_TRIANGLES, 0, 3);	

		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_TEXTURE_2D);
	}

	//////////////////////////////////////////////////////////////////////////
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
	// ÉèÖÃ±ß¿òÑÕÉ«,Èç¹ûÉèÖÃÁËÌî³äÑÕÉ«,¸ÃÉèÖÃÊ§Ð§
	void NDUICircleRect::SetFrameColor(ccColor4B color)
	{
		m_colorFrame = color;
		m_bFrame = true;
	}
	// ÉèÖÃÌî³äÑÕÉ«
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
