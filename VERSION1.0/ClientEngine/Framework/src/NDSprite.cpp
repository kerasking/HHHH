//
//  NDSprite.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-11.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDSprite.h"
#include "CCTextureCache.h"
#include "CCTextureCacheExt.h"
#include "NDPath.h"
#include "NDAnimationGroupPool.h"
#include "NDLayer.h"
#include "NDFrame.h"
#include "NDAnimationGroup.h"
#include "NDMapLayer.h"
#include "NDAutoPath.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "NDLightEffect.h"
#include "Utility.h"
#include "..\ClientLogic\Common\inc\define.h"
#include "..\ClientLogic\Common\inc\NDConstant.h"

using namespace cocos2d;
using namespace NDEngine;

namespace NDEngine
{
IMPLEMENT_CLASS(NDSprite, NDNode)

NDSprite::NDSprite()
{
	m_pkAniGroup = NULL;
	m_pkCurrentAnimation = NULL;
	m_pkFrameRunRecord = NULL;
	m_bReverse = false;
	m_bMoveMap = false;
	m_bIsMoving = false;
	m_nMovePathIndex = 0;

//		NDLog("init pos");
	m_kPosition.x = 0;
	m_kPosition.y = 0;

	m_nCloak = -1;
	m_nColorInfo = -1;
	m_nNPCLookface = -1;

	m_nSpeed = 4;
	m_kTargetPos = CGPointZero;

	m_pkAniGroup = NULL;

	m_pkPicSprite = NULL;

	m_kRectSprite = CGRectZero;

	m_bNonRole = false;

//set images
// 		m_hairImage = m_faceImage = m_expressionImage = m_capImage = m_armorImage = m_rightHandWeaponImage = m_leftHandWeaponImage = NULL;
// 		m_doubleHandWeaponImage = m_dualSwordImage = m_dualKnifeImage = m_doubleHandWandImage = m_doubleHandBowImage = m_shieldImage = NULL;
// 		m_faqiImage = m_cloakImage = m_doubleHandSpearImage = m_leftShoulderImage = m_rightShoulderImage = m_skirtStandImage = m_skirtWalkImage = NULL;
// 		m_skirtSitImage = m_skirtLiftLegImage = colorInfoImage = NULL;

	m_nMasterWeaponType = 0;
	m_nSecondWeaponType = 0;
	m_nMasterWeaponQuality = 0;
	m_nSecondWeaponQuality = 0;
	m_nCapQuality = 0;
	m_nArmorQuality = 0;
	m_nCloakQuality = 0;

	m_bFaceRight = true;
	m_fScale = 1.0f;

	m_bHightLight = false;

	m_dBeginTime = 0.0;
}

NDSprite::~NDSprite()
{
	CC_SAFE_RELEASE (m_pkAniGroup);
	CC_SAFE_RELEASE (m_pkFrameRunRecord);
}

void NDSprite::Initialization(const char* sprFile)
{
	NDNode::Initialization();
	m_pkAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSpr(
			sprFile);
}

void NDSprite::SetCurrentAnimation(int nAnimationIndex, bool bReverse)
{
	//NDLog("animationIndex%d",animationIndex);
	if (m_pkAniGroup)
	{
		if (nAnimationIndex < 0
				|| nAnimationIndex
						>= (int) m_pkAniGroup->getAnimations()->count())
		{
			return;
		}

		m_bReverse = bReverse;

		if (m_pkCurrentAnimation == NULL
				|| m_pkCurrentAnimation->getType() == ANIMATION_TYPE_ONCE_END
				|| m_pkCurrentAnimation->getType() == ANIMATION_TYPE_ONCE_START
				|| m_pkCurrentAnimation->getCurIndexInAniGroup()
						!= 1)
		{
			m_pkCurrentAnimation =
					(NDAnimation*) m_pkAniGroup->getAnimations()->objectAtIndex(
							nAnimationIndex);
			m_pkCurrentAnimation->setCurIndexInAniGroup(nAnimationIndex);
			CC_SAFE_RELEASE_NULL (m_pkFrameRunRecord);
			SAFE_RELEASE(m_pkFrameRunRecord);
			m_pkFrameRunRecord = new NDFrameRunRecord;
		}

		SetContentSize(
				CGSizeMake(m_pkCurrentAnimation->getW(),
						m_pkCurrentAnimation->getH()));
	}
}

void NDSprite::RunAnimation(bool bDraw)
{
	if (m_pkFrameRunRecord && m_pkAniGroup && m_pkCurrentAnimation)
	{
		if (m_bIsMoving)
		{
			//else
//				{
			int iPoints = m_kPointList.size();
			if (m_nMovePathIndex < iPoints)
			{
				if (m_nMovePathIndex == 0)
				{
					OnMoveBegin();
				}
				else
				{
					OnMoving(m_nMovePathIndex == iPoints - 1);
				}

				CGPoint kPos = m_kPointList.at(m_nMovePathIndex++);
				SetPosition(kPos);
			}
			else
			{
				OnMoveEnd();
				m_bIsMoving = false;
			}
			//	}

		}

		NDNode* pkNode = GetParent();

		if (!pkNode)
		{
			return;
		}

		m_pkAniGroup->setRuningSprite(this);
		m_pkAniGroup->setRunningMapSize(pkNode->GetContentSize());
		m_pkAniGroup->setPosition(m_kPosition);

		m_pkCurrentAnimation->setReverse(m_bReverse);

		bool bIsOldTitleHightLight = IsTileHightLight();
		TileSetHightLight (m_bHightLight);

		bool bRet = OnDrawBegin(bDraw);

		if (bRet)
		{
			standAction(true);
			m_pkCurrentAnimation->runWithRunFrameRecord(m_pkFrameRunRecord,
					bDraw, m_fScale);
		}

		OnDrawEnd(bDraw);

		TileSetHightLight(bIsOldTitleHightLight);

		if (m_bMoveMap && pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			NDMapLayer* mapLayer = (NDMapLayer*) pkNode;
			mapLayer->SetScreenCenter(m_kPosition);
		}
	}
	else if (m_pkPicSprite)
	{
		if (GetParent())
		{
			CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
			NDNode* layer = GetParent();

			if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
			{
				bool bRet = OnDrawBegin(bDraw);

				if (bDraw && bRet)
				{
					CGSize sizemap = layer->GetContentSize();
					CGSize size = m_pkPicSprite->GetSize();

					m_pkPicSprite->DrawInRect(
							CGRectMake(GetPosition().x,
									GetPosition().y + winsize.height
											- sizemap.height, size.width,
									size.height));
				}

				OnDrawEnd(bDraw);
			}
		}
	}
}

void NDSprite::SetPosition(CGPoint newPosition)
{
//		NDLog("new pos:%f,%f",newPosition.x, newPosition.y);
	m_kPosition = CGPointMake(newPosition.x, newPosition.y);
}

void NDSprite::MoveToPosition(std::vector<CGPoint> kToPos, SpriteSpeed speed,
		bool moveMap, bool ignoreMask/*=false*/, bool mustArrive/*=false*/)
{
	int iSize = kToPos.size();
	if (iSize == 0)
	{
		return;
	}

	if (GetParent())
	{
		NDNode* pkLayer = GetParent();
		if (pkLayer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			m_bMoveMap = moveMap;
			m_bIsMoving = true;
			m_nSpeed = speed;

			//CGPoint pos = GetPosition();
//				if ( ((int)pos.x-DISPLAY_POS_X_OFFSET) % 16 != 0 || 
//					 ((int)pos.y-DISPLAY_POS_Y_OFFSET) % 16 != 0)
//				{ // Cell没走完,又设置新的目标
//					m_targetPos = toPos;
//					return;
//				}

			m_nMovePathIndex = 0;
			m_kPointList.clear();

			CGPoint from = m_kPosition;
			for (int i = 0; i < iSize; i++)
			{
				CGPoint to = kToPos[i];
				std::vector < CGPoint > kPointList;
				NDAutoPath::sharedAutoPath()->autoFindPath(from, to,
						(NDMapLayer*) pkLayer, m_nSpeed, mustArrive, ignoreMask);
				kPointList = NDAutoPath::sharedAutoPath()->getPathPointVetor();

				if (!kPointList.empty())
				{
					m_kPointList.insert(m_kPointList.end(), kPointList.begin(),
							kPointList.end());
					from = m_kPointList[m_kPointList.size() - 1];
				}
			}

			if (m_kPointList.empty())
			{
				m_bIsMoving = false;
			}

			//m_pointList = NDAutoPath::sharedAutoPath()->getPathPointVetor();

		}
	}
}

void NDSprite::OnMoveBegin()
{

}

void NDSprite::OnMoving(bool bLastPos)
{

}

void NDSprite::OnMoveEnd()
{

}

CGPoint NDSprite::GetPosition()
{
	return m_kPosition;
}

void NDSprite::stopMoving()
{
	m_bIsMoving = false;
	m_kPointList.clear();
	m_nMovePathIndex = 0;
}

int NDSprite::GetOrder()
{
	return m_kPosition.y + 16;
}

void NDSprite::SetSprite(NDPicture* pkPicture)
{
	m_pkPicSprite = pkPicture;

	if (pkPicture)
	{
		CGPoint point = GetPosition();
		CGSize size = pkPicture->GetSize();
		m_kRectSprite = CGRectMake(point.x, point.y, size.width, size.height);
	}
}

bool NDSprite::IsAnimationComplete()
{
	return m_pkCurrentAnimation == NULL ?
			true : m_pkFrameRunRecord->getIsCompleted();
}

int NDSprite::GetCurFrameIndex()
{
	return m_pkFrameRunRecord == NULL ?
			0 : m_pkFrameRunRecord->getCurrentFrameIndex();
}

CGRect NDSprite::GetSpriteRect()
{
	if (m_pkCurrentAnimation)
	{
		m_pkAniGroup->setPosition(m_kPosition);
		return m_pkCurrentAnimation->getRect();
	}

	if (m_pkPicSprite)
	{
		return m_kRectSprite;
	}
	return CGRectZero;
}

void NDSprite::SetHairImage(const char* imageFile, int colorIndex)
{
	if (imageFile)
	{
		tq::CString str("%s@%d", imageFile, colorIndex - 1);
		m_strHairImage = str;
		//todo(zjh)
		//CCTextureCache::sharedTextureCache()->addColorImage(m_hairImage);
	}

//		stringstream ss;
//		ss << imageFile << "@" << (colorIndex - 1);
//		m_hairImage = ss.str();
//		
//		if (!m_hairImage.empty())
//		{
//			[[CCTextureCache sharedTextureCache] addColorImage:[NSString stringWithUTF8String:m_hairImage.c_str()]];
//		}
}

void NDSprite::SetFaceImage(const char* imageFile)
{
	//m_faceImage = imageFile;
	if (imageFile)
	{
		m_strFaceImage = imageFile;
	}
}

void NDSprite::SetExpressionImage(const char* imageFile)
{
	//m_expressionImage = imageFile;
	if (imageFile)
	{
		m_strExpressionImage = imageFile;
	}
}

void NDSprite::SetCapImage(const char* imageFile)
{
	//m_capImage = imageFile;
	if (imageFile)
	{
		m_strCapImage = imageFile;
	}
}

void NDSprite::SetArmorImage(const char* imageFile)
{
	//m_armorImage = imageFile;
	if (imageFile)
	{
		m_strArmorImage = imageFile;
	}
}

void NDSprite::SetRightHandWeaponImage(const char* imageFile)
{
	//m_rightHandWeaponImage = imageFile;
	if (imageFile)
	{
		m_strRightHandWeaponImage = imageFile;
	}
}

void NDSprite::SetLeftHandWeaponImage(const char* imageFile)
{
	//m_leftHandWeaponImage = imageFile;
	if (imageFile)
	{
		m_strLeftHandWeaponImage = imageFile;
	}
}

void NDSprite::SetDoubleHandWeaponImage(const char* imageFile)
{
	//m_doubleHandWeaponImage = imageFile;
	if (imageFile)
	{
		m_strDoubleHandWeaponImage = imageFile;
	}
}

void NDSprite::SetDualSwordImage(const char* imageFile)
{
	//m_dualSwordImage = imageFile;
	if (imageFile)
	{
		m_strDualSwordImage = imageFile;
	}
}

void NDSprite::SetDualKnifeImage(const char* imageFile)
{
	//m_dualKnifeImage = imageFile;
	if (imageFile)
	{
		m_strDualKnifeImage = imageFile;
	}
}

void NDSprite::SetDoubleHandWandImage(const char* imageFile)
{
	//m_doubleHandWandImage = imageFile;
	if (imageFile)
	{
		m_strDoubleHandWandImage = imageFile;
	}
}

void NDSprite::SetDoubleHandBowImage(const char* imageFile)
{
	//m_doubleHandBowImage = imageFile;
	if (imageFile)
	{
		m_strDoubleHandBowImage = imageFile;
	}
}

void NDSprite::SetShieldImage(const char* imageFile)
{
	//m_shieldImage = imageFile;
	if (imageFile)
	{
		m_strShieldImage = imageFile;
	}
}

void NDSprite::SetFaqiImage(const char* imageFile)
{
	//m_faqiImage = imageFile;
	if (imageFile)
	{
		m_strFaqiImage = imageFile;
	}
}

void NDSprite::SetCloakImage(const char* imageFile)
{
	//m_cloakImage = imageFile;
	if (imageFile)
	{
		m_strCloakImage = imageFile;
	}
}
///////////////////////////////////////////////////

void NDSprite::SetLeftShoulderImage(const char* imageFile)
{
	//m_leftShoulderImage = imageFile;
	if (imageFile)
	{
		m_strLeftShoulderImage = imageFile;
	}
}

void NDSprite::SetRightShoulderImage(const char* imageFile)
{
	//m_rightShoulderImage= imageFile;
	if (imageFile)
	{
		m_strRightShoulderImage = imageFile;
	}
}

void NDSprite::SetSkirtStandImage(const char* imageFile)
{
	//m_skirtStandImage = imageFile;
	if (imageFile)
	{
		m_strSkirtStandImage = imageFile;
	}
}

void NDSprite::SetSkirtWalkImage(const char* imageFile)
{
	//m_skirtWalkImage = imageFile;
	if (imageFile)
	{
		m_strSkirtWalkImage = imageFile;
	}
}

void NDSprite::SetSkirtSitImage(const char* imageFile)
{
	//m_skirtSitImage = imageFile;
	if (imageFile)
	{
		m_strSkirtSitImage = imageFile;
	}
}

void NDSprite::SetSkirtLiftLegImage(const char* imageFile)
{
	//m_skirtLiftLegImage = imageFile;
	if (imageFile)
	{
		m_strSkirtLiftLegImage = imageFile;
	}
}
///////////////////////////////////////////////////

void NDSprite::SetDoubleHandSpearImage(const char* imageFile)
{
	//m_doubleHandSpearImage = imageFile;
	if (imageFile)
	{
		m_strDoubleHandSpearImage = imageFile;
	}
}

CCTexture2D *NDSprite::GetHairImage()
{
	if (!m_strHairImage.empty())
	{
		//todo(zjh)
		//return [[CCTextureCache sharedTextureCache] addColorImage:m_hairImage];
	}
	return NULL;
}

CCTexture2D *NDSprite::GetFaceImage()
{
	if (!m_strFaceImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strFaceImage.c_str());
	}
	return NULL;

}

CCTexture2D *NDSprite::GetExpressionImage()
{
	if (!m_strExpressionImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strExpressionImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetCapImage()
{
	if (!m_strCapImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strCapImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetArmorImage()
{
	if (!m_strArmorImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strArmorImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetRightHandWeaponImage()
{
	if (m_strRightHandWeaponImage.empty() || m_nMasterWeaponType != ONE_HAND_WEAPON)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strRightHandWeaponImage.c_str());
}

CCTexture2D *NDSprite::GetLeftHandWeaponImage()
{
	if (m_strLeftHandWeaponImage.empty() || m_nSecondWeaponType != ONE_HAND_WEAPON)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strLeftHandWeaponImage.c_str());
}

CCTexture2D *NDSprite::GetDoubleHandWeaponImage()
{
	if (m_strDoubleHandWeaponImage.empty() || m_nMasterWeaponType != TWO_HAND_WEAPON)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDoubleHandWeaponImage.c_str());
}

CCTexture2D *NDSprite::GetDualSwordImage()
{
	if (m_strDualSwordImage.empty() || m_nMasterWeaponType != DUAL_SWORD)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDualSwordImage.c_str());
}

CCTexture2D *NDSprite::GetDualKnifeImage()
{
	if (m_strDualKnifeImage.empty() || m_nMasterWeaponType != DUAL_KNIFE)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDualKnifeImage.c_str());
}

CCTexture2D *NDSprite::GetDoubleHandWandImage()
{
	if (m_strDoubleHandWandImage.empty() || m_nMasterWeaponType != TWO_HAND_WAND)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDoubleHandWandImage.c_str());
}

CCTexture2D *NDSprite::GetDoubleHandBowImage()
{
	if (m_strDoubleHandBowImage.empty() || m_nMasterWeaponType != TWO_HAND_BOW)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDoubleHandBowImage.c_str());
}

CCTexture2D *NDSprite::GetShieldImage()
{
	if (m_strShieldImage.empty() || m_nSecondWeaponType != SEC_SHIELD)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(m_strShieldImage.c_str());
}

CCTexture2D *NDSprite::GetFaqiImage()
{
	if (m_strFaqiImage.empty() || m_nSecondWeaponType != SEC_FAQI)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(m_strFaqiImage.c_str());
}

CCTexture2D *NDSprite::GetCloakImage()
{
	if (!m_strCloakImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strCloakImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetLeftShoulderImage()
{
	if (!m_strLeftShoulderImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strLeftShoulderImage.c_str());
	}
	return NULL;

}

CCTexture2D *NDSprite::GetRightShoulderImage()
{
	if (!m_strRightShoulderImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strRightShoulderImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetSkirtStandImage()
{
	if (!m_strSkirtStandImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strSkirtStandImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetSkirtWalkImage()
{
	if (!m_strSkirtWalkImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strSkirtWalkImage.c_str());
	}
	return NULL;

}

CCTexture2D *NDSprite::GetSkirtSitImage()
{
	if (!m_strSkirtSitImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strSkirtSitImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetSkirtLiftLegImage()
{
	if (!m_strSkirtLiftLegImage.empty())
	{
		return CCTextureCache::sharedTextureCache()->addImage(
				m_strSkirtLiftLegImage.c_str());
	}
	return NULL;
}

CCTexture2D *NDSprite::GetDoubleHandSpearImage()
{
	if (m_strDoubleHandSpearImage.empty() || m_nMasterWeaponType != TWO_HAND_SPEAR)
	{
		return NULL;
	}
	return CCTextureCache::sharedTextureCache()->addImage(
			m_strDoubleHandSpearImage.c_str());
}

// 	CCTexture2D* NDSprite::getColorTexture(int imageIndex, NDAnimationGroup* animationGroup)
// 	{
// 		CCTexture2D* tex = NULL;
// 		// colorinfo特殊处理
// 		if ( animationGroup && colorInfo != -1 ) 
// 		{
// 			if (!colorInfoImage) 
// 			{
// //				stringstream ss;
// //				ss << [[animationGroup.images objectAtIndex:imageIndex] UTF8String]
// //				<< "@" << colorInfo;
// 				colorInfoImage = [[NSString stringWithFormat:@"%@@%d", [animationGroup.images objectAtIndex:imageIndex], colorInfo] retain];
// 			}
// 			
// 			tex = [[CCTextureCache sharedTextureCache] addColorImage:colorInfoImage];
// 			
// 			if (!tex)
// 			{
// 				[colorInfoImage release];
// 				colorInfoImage = [[animationGroup.images objectAtIndex:imageIndex] retain];
// 				tex = [[CCTextureCache sharedTextureCache] addImage:colorInfoImage];
// 			}
// 			
// 		}	
// 		return tex;
// 	}

CCTexture2D* NDSprite::getNpcLookfaceTexture(int imageIndex,
		NDAnimationGroup* animationGroup)
{
	CCTexture2D* pkTex = NULL;
	if (!animationGroup)
	{
		return NULL;
	}
	std::vector < std::string > *vImg = animationGroup->getImages();
	if (m_nNPCLookface == -1 && vImg && vImg->size() > imageIndex)  //非普通NPC
	{
		pkTex = CCTextureCache::sharedTextureCache()->addImage(
				(*vImg)[imageIndex].c_str());
	}
	return pkTex;
}

int NDSprite::GetHeight()
{
	return m_pkCurrentAnimation->getH();
}

int NDSprite::GetWidth()
{
	return m_pkCurrentAnimation->getW();
}

int NDSprite::getGravityY()
{
	if (m_pkCurrentAnimation == NULL || 0 == m_pkCurrentAnimation->getBottomY())
	{
		return 0;
	}

	return m_pkCurrentAnimation->getBottomY() - m_pkCurrentAnimation->getY();
}

int NDSprite::getGravityX()
{
	if (m_pkCurrentAnimation == NULL || 0 == m_pkCurrentAnimation->getMidX())
	{
		return 0;
	}
	return m_pkCurrentAnimation->getMidX() - m_pkCurrentAnimation->getX();
}

bool NDSprite::GetLastPointOfPath(CGPoint& pos)
{
	size_t count = m_kPointList.size();

	if (count == 0)
	{
		return false;
	}

	pos = m_kPointList[count - 1];

	return true;
}

void NDSprite::SetPlayFrameRange(int nStartFrame, int nEndFrame)
{
	if (m_pkFrameRunRecord)
	{
		m_pkFrameRunRecord->SetPlayRange(nStartFrame, nEndFrame);
	}
}

void NDSprite::SetHightLight(bool bSet)
{
	m_bHightLight = bSet;
}

NDFrame* NDSprite::GetCurrentFrame()
{
	NDFrame *frame = m_pkCurrentAnimation->getFrames()->getObjectAtIndex(
			m_pkFrameRunRecord->getCurrentFrameIndex());
	return frame;
}

cocos2d::CCTexture2D* NDSprite::getColorTexture(int imageIndex,
		NDAnimationGroup* animationGroup)
{
	CCTexture2D* pkTex = 0;

// 	if (animationGroup && 1 != m_nColorInfo)
// 	{
// 		if (0 == m_strColorInfoImage.length())
// 		{
// 			std::vector < std::string > *pkVector = animationGroup->getImages();
// 			m_strColorInfoImage = (*pkVector)[imageIndex];
// 		}
// 
// 		pkPic = NDPicturePool::DefaultPool()->AddPicture(
// 				m_strColorInfoImage.c_str());
// 
// 		if (0 == pkPic)
// 		{
// 			return 0;
// 		}
// 
// 		pkTex = pkPic->GetTexture();
// 	}

	return pkTex;
}

void NDSprite::standAction( bool bStand )
{
	bool bEnd = m_pkCurrentAnimation->lastFrameEnd(m_pkFrameRunRecord);

// 	if (bEnd)
// 	{
// 		int nAnimationMax = (int)m_pkAniGroup->getAnimations()->count();
// 
// 		if (m_pkCurrentAnimation->getCurIndexInAniGroup() == MANUELROLE_RELAX)
// 		{
// 			m_dBeginTime = (double)time(0);
// 		}
// 		else if (m_pkCurrentAnimation->getCurIndexInAniGroup() == MANUELROLE_STAND &&
// 			nAnimationMax > MANUELROLE_RELAX)
// 		{
// 			NSTimeInterval dCurTime = (double)time(0);
// 
// 			if ((dCurTime - m_dBeginTime) > 5 && rand() % 100 > 95)
// 			{
// 				m_dBeginTime = dCurTime;
// 				SetCurrentAnimation(MANUELROLE_RELAX,m_bReverse);
// 				m_pkCurrentAnimation->setReverse(m_bReverse);
// 			}
// 		}
// 		else if (bStand)
// 		{
// 			SetCurrentAnimation(MANUELROLE_STAND,m_bReverse);
// 			m_pkCurrentAnimation->setReverse(m_bReverse);
// 		}
// 	}
}

}