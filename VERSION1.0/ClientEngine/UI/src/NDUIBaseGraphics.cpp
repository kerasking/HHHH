//
//  NDUIBaseGraphics.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-13.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDUIBaseGraphics.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "CCDrawingPrimitives.h"
#include "ccMacros.h"
#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <GLES/gl.h>
#endif

using namespace cocos2d;

namespace NDEngine
{
	void DrawRecttangle(CCRect rect, ccColor4B color)
	{
#if 0
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();

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
#endif

		ccColor4F cr = ccc4FFromccc4B(color);
		ccDrawColor4F( cr.r, cr.g, cr.b, cr.a );

		CCPoint destination = ccp( rect.origin.x + rect.size.width, 
									rect.origin.y + rect.size.height );
		
		ccDrawRect( SCREEN2GL(rect.origin), SCREEN2GL(destination));
	}

	void DrawPolygon(CCRect rect, ccColor4B color, GLuint lineWidth)
	{
// 		//CCAssert(0,"crash me");//@todo: crash me!
// 
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 		float scale		= NDDirector::DefaultDirector()->GetScaleFactor();	
// 
// 		glLineWidth(lineWidth);
// 		glColor4ub(color.r, color.g, color.b, color.a);
// 
// 		if (CompareEqualFloat(scale, 0.0f))
// 		{
// 			CCPoint vertices[4] = {
// 				ccp(rect.origin.x, winSize.height - rect.origin.y - rect.size.height), 
// 				ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y - rect.size.height),
// 				ccp(rect.origin.x + rect.size.width, winSize.height - rect.origin.y),
// 				ccp(rect.origin.x, winSize.height - rect.origin.y)			
// 			}; 
// 			ccDrawPoly(vertices, 4, true);
// 		}
// 		else
// 		{
// 			CCPoint vertices[4] = {
// 				ccp(rect.origin.x / scale, (winSize.height - rect.origin.y - rect.size.height) / scale), 
// 				ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y - rect.size.height) / scale),
// 				ccp((rect.origin.x + rect.size.width) / scale, (winSize.height - rect.origin.y) / scale),
// 				ccp(rect.origin.x / scale, (winSize.height - rect.origin.y) / scale)			
// 			}; 
// 			ccDrawPoly(vertices, 4, true);
// 		}
// 
// 		glColor4ub(255, 255, 255, 255); 
	}

	void DrawLine(CCPoint fromPoint, CCPoint toPoint, ccColor4B color, GLuint lineWidth)
	{	
// 		//CCAssert(0, "crash me");//@todo: crash me!
// 
// 		CCSize winSize	= CCDirector::sharedDirector()->getWinSizeInPixels();
// 		float scale		= NDDirector::DefaultDirector()->GetScaleFactor();
// 
// 		glLineWidth(lineWidth);
// 		glColor4ub(color.r, color.g, color.b, color.a);
// 
// // 		if (CompareEqualFloat(scale, 0.0f))
// // 		{
// // 			ccDrawLine(ccp(fromPoint.x,winSize.height - fromPoint.y), ccp(toPoint.x, winSize.height - toPoint.y));
// // 		}
// // 		else
// // 		{
// // 			ccDrawLine(ccp(fromPoint.x / scale, (winSize.height - fromPoint.y)  / scale), 
// // 				ccp(toPoint.x / scale, (winSize.height - toPoint.y) / scale));
// // 		}
// 
// 		ccDrawLine( SCREEN2GL(fromPoint), SCREEN2GL(toPoint));
// 		
// 		glColor4ub(255, 255, 255, 255);
	}

	void DrawCircle(CCPoint center, float r, float a, int segs, ccColor4B color)
	{
// 		//CCAssert(0, "crash me");//@todo: crash me!
// 
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 		CCPoint glCenter = ccp(center.x, winSize.height - center.y);
// 
// 		glColor4ub(color.r, color.g, color.b, color.a);
// 
// 		int additionalSegment = 1;
// 
// 		const float coef = 2.0f * (float)M_PI/segs;
// 
// 		float *vertices = (float *)malloc( sizeof(float)*2*(segs+2));
// 		if( ! vertices )
// 			return;
// 
// 		memset( vertices,0, sizeof(float)*2*(segs+2));
// 
// 		for(int i=0;i<=segs;i++)
// 		{
// 			float rads = i*coef;
// 			float j = r * cosf(rads + a) + glCenter.x;
// 			float k = r * sinf(rads + a) + glCenter.y;
// 
// 			vertices[i*2] = j;
// 			vertices[i*2+1] =k;
// 		}
// 		vertices[(segs+1)*2] = glCenter.x;
// 		vertices[(segs+1)*2+1] = glCenter.y;
// 
// 		// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
// 		// Needed states: GL_VERTEX_ARRAY, 
// 		// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
// 		glDisable(GL_TEXTURE_2D);
// 		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
// 		glDisableClientState(GL_COLOR_ARRAY);
// 
// 		glVertexPointer(2, GL_FLOAT, 0, vertices);	
// 		glDrawArrays(GL_TRIANGLE_FAN, 0, segs+additionalSegment);
// 
// 		// restore default state
// 		glEnableClientState(GL_COLOR_ARRAY);
// 		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
// 		glEnable(GL_TEXTURE_2D);	
// 
// 		free( vertices );
// 
// 		glColor4ub(255, 255, 255, 255); 
	}

	void DrawFrame(int borderColor, int x, int y, int width, int height) {

// 		int y2 = y + height - 1, x2 = x + width - 1;
// 
// 		ccColor4B clr = INTCOLORTOCCC4(borderColor);
// 		DrawRecttangle(CCRectMake(x - 1, y - 1, 4, 4), clr); // ×óÉÏ½Ç¿ò
// 		DrawRecttangle(CCRectMake(x2 - 3, y - 1, 4, 4), clr); // ÓÒÉÏ½Ç¿ò
// 
// 		DrawRecttangle(CCRectMake(x - 1, y2 - 3, 4, 4), clr); // ×óÏÂ½Ç¿ò
// 		DrawRecttangle(CCRectMake(x2 - 3, y2 - 3, 4, 4), clr); // ÓÒÏÂ½Ç¿ò
// 
// 		DrawLine(CCPointMake(x, y + 5), CCPointMake(x + 5, y + 5), clr, 1);
// 		DrawLine(CCPointMake(x + 5, y), CCPointMake(x + 5, y + 5), clr, 1);
// 		DrawLine(CCPointMake(x2, y + 5), CCPointMake(x2 - 5, y + 5), clr, 1);
// 		DrawLine(CCPointMake(x2 - 5, y), CCPointMake(x2 - 5, y + 5), clr, 1);
// 
// 		DrawLine(CCPointMake(x2, y2 - 5), CCPointMake(x2 - 5, y2 - 5), clr, 1);
// 		DrawLine(CCPointMake(x2 - 5, y2), CCPointMake(x2 - 5, y2 - 5), clr, 1);
// 		DrawLine(CCPointMake(x, y2 - 5), CCPointMake(x + 5, y2 - 5), clr, 1);
// 		DrawLine(CCPointMake(x + 5, y2), CCPointMake(x + 5, y2 - 5), clr, 1);
// 
// 		DrawLine(CCPointMake(x + 5, y), CCPointMake(x + width - 6, y), clr, 1);
// 		DrawLine(CCPointMake(x + 5, y2), CCPointMake(x + width - 6, y2), clr, 1);
// 
// 		DrawLine(CCPointMake(x, y + 5), CCPointMake(x, y2 - 5), clr, 1);
// 		DrawLine(CCPointMake(x2, y + 5), CCPointMake(x2, y2 - 5), clr, 1);
	}

	void DrawTriangle(CCPoint first, CCPoint second, CCPoint third, ccColor4B color)
	{
// 		//CCAssert(0, "crash me");//@todo: crash me!
// 
// 		glDisable(GL_TEXTURE_2D);
// 		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
// 
// 		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
// 
// 		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 
// 		GLfloat vertices[6] = { 
// 			first.x, winSize.height - first.y, 
// 			second.x, winSize.height - second.y, 
// 			third.x, winSize.height - third.y
// 		};
// 
// 		GLubyte colors[12] = {
// 			color.r, color.g, color.b, color.a,
// 			color.r, color.g, color.b, color.a,
// 			color.r, color.g, color.b, color.a,
// 		};
// 
// 		glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
// 		glVertexPointer(2, GL_FLOAT, 0, vertices);		
// 		glDrawArrays(GL_TRIANGLES, 0, 3);	
// 
// 		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);
// 
// 		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
// 		glEnable(GL_TEXTURE_2D);
	}

	//////////////////////////////////////////////////////////////////////////
	IMPLEMENT_CLASS(NDUILine, NDUINode)
	NDUILine::NDUILine()
	{
		m_from = CCPointZero;
		m_to = CCPointZero;
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
			CCRect rect = GetFrameRect();
			if ( int(rect.origin.x) == 0 && int(rect.origin.y) == 0 ) 
			{
				DrawLine(this->m_from, this->m_to, this->m_color, this->m_lineWidth);
			}
			else
			{
				CCRect screenRect = GetScreenRect();
				DrawLine(CCPointMake(m_from.x+screenRect.origin.x, m_from.y+screenRect.origin.y),
							   CCPointMake(m_to.x+screenRect.origin.x, m_to.y+screenRect.origin.y),
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
			CCRect rect = this->GetScreenRect();
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
			CCRect rect = this->GetScreenRect();
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
		//CCRect rect = this->GetFrameRect();
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
			CCRect rect = this->GetScreenRect();
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
				
				DrawRecttangle(CCRectMake(rect.origin.x+m_uiRadius-1, rect.origin.y-1, rect.size.width-2*m_uiRadius+2, rect.size.height+2), m_colorFrame);
				DrawRecttangle(CCRectMake(rect.origin.x-1, rect.origin.y+m_uiRadius-1, rect.size.width+2, rect.size.height-2*m_uiRadius+2), m_colorFrame);
			}
			
			DrawCircle(ccp(rect.origin.x+m_uiRadius, rect.origin.y+m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius, rect.origin.y+m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+m_uiRadius, rect.origin.y+rect.size.height-m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
			DrawCircle(ccp(rect.origin.x+rect.size.width-m_uiRadius, rect.origin.y+rect.size.height-m_uiRadius),
					   m_uiRadius, 0, 10, m_colorFill);
					   
			DrawRecttangle(CCRectMake(rect.origin.x+m_uiRadius, rect.origin.y, rect.size.width-2*m_uiRadius, rect.size.height), m_colorFill);
			DrawRecttangle(CCRectMake(rect.origin.x, rect.origin.y+m_uiRadius, rect.size.width, rect.size.height-2*m_uiRadius), m_colorFill);
		}
	}
	
	//////////////////////////
	IMPLEMENT_CLASS(NDUITriangle, NDUINode)

	NDUITriangle::NDUITriangle()
	{
		m_color = ccc4(255, 255, 255, 255);
		for (int i = 0; i < 3; i++) 
		{
			m_pos[i] = CCPointZero;
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
	
	void NDUITriangle::SetPoints(CCPoint first, CCPoint second, CCPoint third)
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
			CCPoint origin = this->GetScreenRect().origin;
			
			DrawTriangle(ccpAdd(origin, m_pos[0]), 
						 ccpAdd(origin, m_pos[1]), 
						 ccpAdd(origin, m_pos[2]), 
						 m_color);
		}
	}
	
	void NDUITriangle::recacul()
	{
		/*
		this->SetFrameRect(CCRectZero);
		CCRect scrRect = this->GetScreenRect();
		
		int iXMin = m_pos[0].x, iXMax = m_pos[0].x, iYMin = m_pos[0].y, iYMax = m_pos[0].y;
		
		for (int i = 1; i < 3; i++) 
		{
			iXMin = MIN(iXMin, m_pos[i].x);	
			iXMax = MAX(iXMax, m_pos[i].x);
			iYMin = MIN(iYMin, m_pos[i].y);
			iYMax = MAX(iYMax, m_pos[i].y);			
		}
		
		this->SetFrameRect(CCRectMake(iXMin, iYMin, iXMax-iXMin, iYMax-iYMin));
		
		for (int i = 0; i < 3; i++) 
		{
			m_pos[i] = ccp(scrRect.origin.x+m_pos[i].x, scrRect.origin.y+m_pos[i].y);
		}
		*/
	}
}
