#include "NDUIFrame.h"
#include "NDDirector.h"
#include "CCTextureCache.h"
#include "NDUtil.h"
#include "NDPath.h"
//#include "I_Analyst.h"
#include "NDUIBaseGraphics.h"
#include "NDSharedPtr.h"
#include "CCString.h"
#include "ObjectTracker.h"

CCStringRef side_image = new CCString(""); //NSString::stringWithFormat("%s",NDPath::GetImgPath("frame_coner.png"));///< ÕÒ²»µ½NDPath?? ¹ùºÆ

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIFrame, NDUILayer)

	NDUIFrame::NDUIFrame()
	{
		INC_NDOBJ_RTCLS

		m_tileLeftTop = new NDTile;
		m_tileRightTop = new NDTile;
		m_tileLeftBottom = new NDTile;
		m_tileRightBottom = new NDTile;
	}

	NDUIFrame::~NDUIFrame()
	{
		DEC_NDOBJ_RTCLS

		SAFE_RELEASE (m_tileLeftBottom);
		SAFE_RELEASE (m_tileLeftTop);
		SAFE_RELEASE (m_tileRightTop);
		SAFE_RELEASE (m_tileRightBottom);
	}

	void NDUIFrame::draw()
	{
		if (!isDrawEnabled()) return;
		NDUILayer::draw();

		if (IsVisibled())
		{
			drawBackground();

			DrawPolygon(GetScreenRect(), ccc4(24, 85, 82, 255), 3);

			m_tileLeftBottom->draw();
			m_tileLeftTop->draw();
			m_tileRightTop->draw();
			m_tileRightBottom->draw();
		}
	}

	void NDUIFrame::OnFrameRectChange(CCRect srcRect, CCRect dstRect)
	{
		Make();
	}

	void NDUIFrame::Make()
	{
		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
		CCRect scrRect = GetScreenRect();

		NDPicture* ptexpic = NDPicturePool::DefaultPool()->AddPicture( side_image->getCString());
		m_tileLeftTop->setTexture(ptexpic->GetTexture());
		SAFE_DELETE(ptexpic);

		m_tileLeftTop->setCutRect(
			CCRectMake(0, 0,
			m_tileLeftTop->getTexture()->getMaxS()
			* m_tileLeftTop->getTexture()->getPixelsWide(),
			m_tileLeftTop->getTexture()->getMaxT()
			* m_tileLeftTop->getTexture()->getPixelsHigh()));

		m_tileLeftTop->SetDrawRect(
			CCRectMake(scrRect.origin.x, 
						scrRect.origin.y,
						m_tileLeftTop->getTexture()->getMaxS() * m_tileLeftTop->getTexture()->getPixelsWide(),
						m_tileLeftTop->getTexture()->getMaxT() * m_tileLeftTop->getTexture()->getPixelsHigh())); //@android

		m_tileLeftTop->setReverse(false);
		m_tileLeftTop->setRotation(NDRotationEnumRotation0);
		m_tileLeftTop->setMapSize(CCSizeMake(winSize.width, winSize.height));
		m_tileLeftTop->make();

		NDPicture* ppic = NDPicturePool::DefaultPool()->AddPicture( side_image->getCString());
		m_tileLeftTop->setTexture(ppic->GetTexture());
		SAFE_DELETE(ppic);

		m_tileRightTop->setCutRect(
			CCRectMake(0, 0,
			m_tileRightTop->getTexture()->getMaxS()
			* m_tileRightTop->getTexture()->getPixelsWide(),
			m_tileRightTop->getTexture()->getMaxT()
			* m_tileRightTop->getTexture()->getPixelsHigh()));

		m_tileRightTop->SetDrawRect(
			CCRectMake(
			scrRect.origin.x + scrRect.size.width
				- m_tileRightTop->getTexture()->getMaxT() 
					* m_tileRightTop->getTexture()->getPixelsHigh(),
			scrRect.origin.y,
			m_tileRightTop->getTexture()->getMaxT() * m_tileRightTop->getTexture()->getPixelsHigh(),
			m_tileRightTop->getTexture()->getMaxS() * m_tileRightTop->getTexture()->getPixelsWide())); //@android

		m_tileRightTop->setReverse(false);
		m_tileRightTop->setRotation(NDRotationEnumRotation90);
		m_tileRightTop->setMapSize(CCSizeMake(winSize.width, winSize.height));
		m_tileRightTop->make();

		NDPicture* pleftpic = NDPicturePool::DefaultPool()->AddPicture( side_image->getCString());
		m_tileLeftBottom->setTexture(pleftpic->GetTexture());
		SAFE_DELETE(pleftpic);

		m_tileLeftBottom->setCutRect(
			CCRectMake(0, 0,
			m_tileLeftBottom->getTexture()->getMaxS()
			* m_tileLeftBottom->getTexture()->getPixelsWide(),
			m_tileLeftBottom->getTexture()->getMaxT()
			* m_tileLeftBottom->getTexture()->getPixelsHigh()));

		m_tileLeftBottom->SetDrawRect(
			CCRectMake(scrRect.origin.x,
			scrRect.origin.y + scrRect.size.height
				- m_tileLeftBottom->getTexture()->getMaxS()
				* m_tileLeftBottom->getTexture()->getPixelsWide(),
			m_tileLeftBottom->getTexture()->getMaxS()
				* m_tileLeftBottom->getTexture()->getPixelsWide(),
			m_tileLeftBottom->getTexture()->getMaxT()
				* m_tileLeftBottom->getTexture()->getPixelsHigh())); //@android

		m_tileLeftBottom->setReverse(false);
		m_tileLeftBottom->setRotation(NDRotationEnumRotation270);
		m_tileLeftBottom->setMapSize(CCSizeMake(winSize.width, winSize.height));
		m_tileLeftBottom->make();

		NDPicture* prightpic = NDPicturePool::DefaultPool()->AddPicture(side_image->getCString());
		m_tileRightBottom->setTexture(prightpic->GetTexture());
		SAFE_DELETE(prightpic);

		m_tileRightBottom->setCutRect(
			CCRectMake(0, 0,
			m_tileRightBottom->getTexture()->getMaxS()
			* m_tileRightBottom->getTexture()->getPixelsWide(),
			m_tileRightBottom->getTexture()->getMaxT()
			* m_tileRightBottom->getTexture()->getPixelsHigh()));

		m_tileRightBottom->SetDrawRect(
			CCRectMake(
			scrRect.origin.x + scrRect.size.width
				- m_tileRightBottom->getTexture()->getMaxS()
					* m_tileRightBottom->getTexture()->getPixelsWide(),
			scrRect.origin.y + scrRect.size.height
				- m_tileRightBottom->getTexture()->getMaxT()
					* m_tileRightBottom->getTexture()->getPixelsHigh(),
			m_tileRightBottom->getTexture()->getMaxT()
				* m_tileRightBottom->getTexture()->getPixelsHigh(),
			m_tileRightBottom->getTexture()->getMaxS()
				* m_tileRightBottom->getTexture()->getPixelsWide()));//@android

		m_tileRightBottom->setReverse(false);
		m_tileRightBottom->setRotation(NDRotationEnumRotation180);
		m_tileRightBottom->setMapSize(CCSizeMake(winSize.width, winSize.height));
		m_tileRightBottom->make();
	}

	void NDUIFrame::drawBackground()
	{
		CCRect rect = GetScreenRect();
		DrawRecttangle(rect, ccc4(228, 219, 169, 255));
	}
}