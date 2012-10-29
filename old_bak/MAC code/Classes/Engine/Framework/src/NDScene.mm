//
//  NDScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDScene.h"
#include "NDDirector.h"
#include "NDUILayer.h"
#include "NDUILabel.h"
#include "ScriptCommon.h"
#include <sstream>
namespace NDEngine
{
	class CTextLayer : public NDUILayer
	{
		DECLARE_CLASS(CTextLayer)
	public:
		void Initialization()
		{
			NDUILayer::Initialization();
			CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
			m_lbCurTextureSize	= new NDUILabel;
			m_lbCurTextureSize->Initialization();
			m_lbCurTextureSize->SetFrameRect(CGRectMake(winsize.width*0.75, winsize.height*0.9, winsize.width*0.3, winsize.height*0.1));
			m_lbCurTextureSize->SetTextAlignment(LabelTextAlignmentCenter);
			m_lbCurTextureSize->SetFontSize(10);
			m_lbCurTextureSize->SetFontColor(ccc4(0, 0, 255, 255));
           // m_lbCurTextureSize->SetVisible(false);
			this->AddChild(m_lbCurTextureSize);
		}
		bool TouchBegin(NDTouch* touch)
		{
			return false;
		}
		void draw()
		{
			static unsigned int n = 0;
			n++;
			if ( (n % 48) == 0 )
			{
				std::stringstream ss;
				int nSize	= PicMemoryUsingLogOut(true);
				ss << nSize / 1024 << "K," << nSize / (1024 * 1024) << "M";
				m_lbCurTextureSize->SetText(ss.str().c_str());
                m_lbCurTextureSize->SetVisible(false);
			}
		}
	private:
		NDUILabel* m_lbCurTextureSize;
	};
	IMPLEMENT_CLASS(CTextLayer, NDUILayer)
	IMPLEMENT_CLASS(NDScene, NDNode)
	
	
	NDScene::NDScene()
	{	
		
	}
	
	NDScene::~NDScene()
	{
		
	}
	
	NDScene* NDScene::Scene()
	{
		NDScene *scene = new NDScene();
		scene->Initialization();
		return scene;
	}
	void NDScene::Initialization()
	{
		NDNode::Initialization();
//#ifdef DEBUG
        
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		CTextLayer* layer = new CTextLayer;
		layer->Initialization();
		//layer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
        layer->SetTouchEnabled(false);
		this->AddChild(layer, 60000);
         
//#endif
	}
}