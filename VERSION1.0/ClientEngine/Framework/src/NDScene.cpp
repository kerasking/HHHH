//
//  NDScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (����)DeNA. All rights reserved.
//

#include "NDScene.h"
#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDDirector.h"
#include <sstream>
#include "EngineScriptCommon.h"
#include "ObjectTracker.h"

using namespace std;

namespace NDEngine
{

class CTextLayer: public NDUILayer
{
	DECLARE_CLASS (CTextLayer)
public:
	void Initialization()
	{
		NDUILayer::Initialization();
		CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
		m_pkCurTextureSizeLabel = new NDUILabel;
		m_pkCurTextureSizeLabel->Initialization();
		m_pkCurTextureSizeLabel->SetFrameRect(
				CCRectMake(kWinSize.width * 0.75f, kWinSize.height * 0.9f,
						kWinSize.width * 0.3f, kWinSize.height * 0.1f));
		m_pkCurTextureSizeLabel->SetTextAlignment(LabelTextAlignmentCenter);
		m_pkCurTextureSizeLabel->SetFontSize(10);
		m_pkCurTextureSizeLabel->SetFontColor(ccc4(0, 0, 255, 255));
		this->AddChild(m_pkCurTextureSizeLabel);
	}
	bool TouchBegin(NDTouch* touch)
	{
		return false;
	}
	void draw()
	{
		static unsigned int uiNumber = 0;
		uiNumber++;
		if ((uiNumber % 48) == 0)
		{
			std::stringstream kStringStream;
			int nSize = PicMemoryUsingLogOut(true);
			kStringStream << nSize / 1024 << "K," << nSize / (1024 * 1024)
					<< "M";
			m_pkCurTextureSizeLabel->SetText(kStringStream.str().c_str());
			m_pkCurTextureSizeLabel->SetVisible(false);
		}
	}
private:
	NDUILabel* m_pkCurTextureSizeLabel;
};

IMPLEMENT_CLASS(CTextLayer, NDUILayer)
IMPLEMENT_CLASS(NDScene, NDNode)

NDScene::NDScene()
{
	INC_NDOBJ_RTCLS
}

NDScene::~NDScene()
{
	DEC_NDOBJ_RTCLS
}

NDScene* NDScene::Scene()
{
	NDScene *pkScene = new NDScene();
	pkScene->Initialization();
	return pkScene;
}

void NDScene::Initialization()
{
	NDNode::Initialization();
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();

	//CTextLayer *layer = new CTextLayer;
	//layer->Initialization();
	//layer->SetTouchEnabled(false);
	//AddChild(layer, 60000);
}

}
