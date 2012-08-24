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

using namespace cocos2d;
using namespace NDEngine;

namespace NDEngine
{
	IMPLEMENT_CLASS(NDSprite, NDNode)
	
	NDSprite::NDSprite()
	{
		m_aniGroup = NULL;
		m_currentAnimation = NULL;
		m_frameRunRecord = NULL;
		m_reverse = false;
		m_moveMap = false;
		m_moving  = false;
		m_movePathIndex = 0;

//		NDLog("init pos");
		m_position.x = 0;
		m_position.y = 0;
		
		cloak = -1;
		colorInfo = -1;
		npcLookface = -1;
		
		m_iSpeed = 4;
		m_targetPos  = CGPointZero;
		
		m_aniGroup = NULL;
		
		m_picSprite = NULL;
		
		m_rectSprite = CGRectZero;
		
		m_bNonRole = false;
		
		//set images
// 		m_hairImage = m_faceImage = m_expressionImage = m_capImage = m_armorImage = m_rightHandWeaponImage = m_leftHandWeaponImage = NULL;
// 		m_doubleHandWeaponImage = m_dualSwordImage = m_dualKnifeImage = m_doubleHandWandImage = m_doubleHandBowImage = m_shieldImage = NULL;
// 		m_faqiImage = m_cloakImage = m_doubleHandSpearImage = m_leftShoulderImage = m_rightShoulderImage = m_skirtStandImage = m_skirtWalkImage = NULL;
// 		m_skirtSitImage = m_skirtLiftLegImage = colorInfoImage = NULL;
		
		m_weaponType = m_secWeaponType = m_weaponQuality = m_secWeaponQuality = m_capQuality = m_armorQuality = m_cloakQuality = 0;
		
		m_faceRight = true;
		scale = 1.0f;
		
		m_bHightLight = false;
	}
	
	NDSprite::~NDSprite()
	{	
		CC_SAFE_RELEASE(m_aniGroup);
		CC_SAFE_RELEASE(m_frameRunRecord);
	}
	
	void NDSprite::Initialization(const char* sprFile)
	{
		NDNode::Initialization();	
		m_aniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSpr(sprFile);		
	}
	
	void NDSprite::SetCurrentAnimation(int animationIndex, bool reverse)
	{
		//NDLog("animationIndex%d",animationIndex);
		if (m_aniGroup)
		{
			if (animationIndex < 0 ||
				animationIndex >= (int)m_aniGroup->getAnimations()->count())
			{
				return;
			}
		
			m_reverse = reverse;
			
			if (m_currentAnimation == NULL ||
			    m_currentAnimation->getType() == ANIMATION_TYPE_ONCE_END ||
			    m_currentAnimation->getType() == ANIMATION_TYPE_ONCE_START ||
			    this->m_currentAnimation->getCurIndexInAniGroup() != animationIndex) 
			{
				m_currentAnimation = (NDAnimation*)m_aniGroup->
					getAnimations()->objectAtIndex(animationIndex);
				m_currentAnimation->setCurIndexInAniGroup(animationIndex);
				CC_SAFE_RELEASE_NULL(m_frameRunRecord);
				SAFE_RELEASE(m_frameRunRecord);
				m_frameRunRecord = new NDFrameRunRecord;	
			}
			
			this->SetContentSize(CGSizeMake(m_currentAnimation->getW(),
				m_currentAnimation->getH()));
		}	
	}
	
	void NDSprite::RunAnimation(bool bDraw)
	{
		if (m_frameRunRecord && m_aniGroup && m_currentAnimation) 
		{
			if (m_moving) 
			{	
				//else 
//				{
					int iPoints = m_pointList.size();
					if (m_movePathIndex < iPoints)
					{
						if (m_movePathIndex == 0)
						{
							this->OnMoveBegin();
						}
						else 
						{
							this->OnMoving(m_movePathIndex == iPoints - 1);
						}
						
						CGPoint pos = m_pointList.at(m_movePathIndex++);
//						if (m_movePathIndex < (int)m_pointList.size() && m_movePathIndex > 2)
//						{
//							CGPoint prePos = this->GetPosition();
//							CGPoint nextPos = m_pointList[m_movePathIndex];
//							
//							if (prePos.y == pos.y && prePos.x != pos.x)
//							{
//								if (pos.x == nextPos.x && pos.y != nextPos.y) 
//								{
//									OnMoveTurning(true, nextPos.y > pos.y);
//								}
//							}
//							else if (prePos.x == pos.x && prePos.y != pos.y)
//							{
//								if (pos.y == nextPos.y && pos.x != nextPos.x) 
//								{
//									OnMoveTurning(false, nextPos.x > pos.x);
//								}
//							}
//						}
						
						this->SetPosition(pos);
					}
					else
					{
						this->OnMoveEnd();
						m_moving = false;
					}
			//	}
				
			}
			
			NDNode* node = this->GetParent();
			
			if (!node) return;
			
			m_aniGroup->setRuningSprite(this);
			m_aniGroup->setRunningMapSize(node->GetContentSize());
			m_aniGroup->setPosition(m_position);

			m_currentAnimation->setReverse(m_reverse);
			
			bool oldTitleHightLight = IsTileHightLight();
			TileSetHightLight(m_bHightLight);
			
			bool bRet = OnDrawBegin(bDraw);

			if (bRet)
			{
				m_currentAnimation->runWithRunFrameRecord(m_frameRunRecord,
					bDraw, scale);
			}

			OnDrawEnd(bDraw);
			
			TileSetHightLight(oldTitleHightLight);
			
			if (m_moveMap && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
			{
				NDMapLayer* mapLayer = (NDMapLayer*)node;
				mapLayer->SetScreenCenter(m_position);			
			}
		}
		else if(m_picSprite)
		{
			if (GetParent()) 
			{
				CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
				NDNode* layer = this->GetParent();

				if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
				{
					bool bRet = OnDrawBegin(bDraw);

					if (bDraw && bRet)
					{
						CGSize sizemap = layer->GetContentSize();
						CGSize size = m_picSprite->GetSize();

						m_picSprite->DrawInRect(CGRectMake(GetPosition().x, 
							GetPosition().y + winsize.height - sizemap.height,
							size.width, size.height));
					}

					OnDrawEnd(bDraw);
				}
			}
		}
	}
	
	void NDSprite::SetPosition(CGPoint newPosition)
	{
//		NDLog("new pos:%f,%f",newPosition.x, newPosition.y);
		this->m_position = CGPointMake(newPosition.x, newPosition.y);
	}
	
	void NDSprite::MoveToPosition(std::vector<CGPoint> toPos,
		SpriteSpeed speed, bool moveMap, 
		bool ignoreMask/*=false*/, bool mustArrive/*=false*/)
	{
		int iSize = toPos.size();
		if (iSize == 0) 
		{
			return;
		}
		
		if (this->GetParent()) 
		{
			NDNode* layer = this->GetParent();
			if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
			{
				m_moveMap = moveMap;
				m_moving  = true;
				m_iSpeed = speed;
			
				//CGPoint pos = GetPosition();
//				if ( ((int)pos.x-DISPLAY_POS_X_OFFSET) % 16 != 0 || 
//					 ((int)pos.y-DISPLAY_POS_Y_OFFSET) % 16 != 0)
//				{ // Cell没走完,又设置新的目标
//					m_targetPos = toPos;
//					return;
//				}
				
				
				m_movePathIndex = 0;
				m_pointList.clear();
				
				CGPoint from = m_position;
				for (int i = 0; i < iSize; i++) 
				{
					CGPoint to = toPos[i];
					std::vector<CGPoint> pointlist;
					NDAutoPath::sharedAutoPath()->autoFindPath(from, to,
						(NDMapLayer*)layer, m_iSpeed, mustArrive, ignoreMask);
					pointlist = NDAutoPath::sharedAutoPath()->getPathPointVetor();
					
					if (!pointlist.empty()) 
					{
						m_pointList.insert(m_pointList.end(), pointlist.begin(), pointlist.end());
						from = m_pointList[m_pointList.size() - 1];
					}
				}
				
				if (m_pointList.empty())
				{
					m_moving  = false; 
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
		return m_position;
	}
	
	void NDSprite::stopMoving()
	{ 
		m_moving = false; 
		m_pointList.clear();
		m_movePathIndex = 0;
	}
	
	int NDSprite::GetOrder()
	{
		return m_position.y + 16;
	}
	
	void NDSprite::SetSprite(NDPicture* pkPicture)
	{
		m_picSprite = pkPicture;

		if (pkPicture)
		{
			CGPoint point = this->GetPosition();
			CGSize size = pkPicture->GetSize();
			m_rectSprite = CGRectMake(point.x, point.y,
				size.width, size.height);
		}
	}
	
	bool NDSprite::IsAnimationComplete()
	{
//		return m_currentAnimation == NULL ? true : m_frameRunRecord->getIsCompleted(); ///< 临时性注释 郭浩
		return false;
	}
	
	int NDSprite::GetCurFrameIndex()
	{
		return m_frameRunRecord == NULL ? 0 : m_frameRunRecord->getCurrentFrameIndex();
	}
	
	CGRect NDSprite::GetSpriteRect()
	{
		if (m_currentAnimation) 
		{
			m_aniGroup->setPosition(m_position);
			return m_currentAnimation->getRect();
		}
		
		if (m_picSprite)
		{
			return m_rectSprite;
		}
		return CGRectZero;
	}
	
		
	void NDSprite::SetHairImage(const char* imageFile, int colorIndex)
	{
		if (imageFile) 
		{
			tq::CString str("%s@%d", imageFile, colorIndex - 1);
			m_hairImage = str;
			//todo(zjh)
			//CCTextureCache::sharedTextureCache()->addColorImage(m_hairImage);
		}
		
//		stringstream ss;
//		ss << imageFile << "@" << (colorIndex - 1);
//		this->m_hairImage = ss.str();
//		
//		if (!this->m_hairImage.empty())
//		{
//			[[CCTextureCache sharedTextureCache] addColorImage:[NSString stringWithUTF8String:this->m_hairImage.c_str()]];
//		}
	}
	
	void NDSprite::SetFaceImage(const char* imageFile)
	{
		//m_faceImage = imageFile;
		if (imageFile)
		{
			m_faceImage = imageFile;
		}
	}
	
	void NDSprite::SetExpressionImage(const char* imageFile)
	{
		//m_expressionImage = imageFile;
		if (imageFile)
		{
			m_expressionImage = imageFile;
		}
	}
	
	void NDSprite::SetCapImage(const char* imageFile)
	{
		//m_capImage = imageFile;
		if (imageFile)
		{
			m_capImage = imageFile;
		}
	}
	
	void NDSprite::SetArmorImage(const char* imageFile)
	{
		//m_armorImage = imageFile;
		if (imageFile)
		{
			m_armorImage = imageFile;
		}
	}
	
	void NDSprite::SetRightHandWeaponImage(const char* imageFile)
	{
		//m_rightHandWeaponImage = imageFile;
		if (imageFile)
		{
			m_rightHandWeaponImage = imageFile;
		}
	}
	
	void NDSprite::SetLeftHandWeaponImage(const char* imageFile)
	{
		//m_leftHandWeaponImage = imageFile;
		if (imageFile)
		{
			m_leftHandWeaponImage = imageFile;
		}
	}
	
	void NDSprite::SetDoubleHandWeaponImage(const char* imageFile)
	{
		//m_doubleHandWeaponImage = imageFile;
		if (imageFile)
		{
			m_doubleHandWeaponImage = imageFile;
		}
	}
	
	void NDSprite::SetDualSwordImage(const char* imageFile)
	{
		//m_dualSwordImage = imageFile;
		if (imageFile)
		{
			m_dualSwordImage = imageFile;
		}
	}
	
	void NDSprite::SetDualKnifeImage(const char* imageFile)
	{
		//m_dualKnifeImage = imageFile;
		if (imageFile)
		{
			m_dualKnifeImage = imageFile;
		}
	}
	
	void NDSprite::SetDoubleHandWandImage(const char* imageFile)
	{
		//m_doubleHandWandImage = imageFile;
		if (imageFile)
		{
			m_doubleHandWandImage = imageFile;
		}
	}
	
	void NDSprite::SetDoubleHandBowImage(const char* imageFile)
	{
		//m_doubleHandBowImage = imageFile;
		if (imageFile)
		{
			m_doubleHandBowImage = imageFile;
		}
	}
	
	void NDSprite::SetShieldImage(const char* imageFile)
	{
		//m_shieldImage = imageFile;
		if (imageFile)
		{
			m_shieldImage = imageFile;
		}
	}
	
	void NDSprite::SetFaqiImage(const char* imageFile)
	{
		//m_faqiImage = imageFile;
		if (imageFile)
		{
			m_faqiImage = imageFile;
		}
	}
	
	void NDSprite::SetCloakImage(const char* imageFile)
	{
		//m_cloakImage = imageFile;
		if (imageFile)
		{
			m_cloakImage = imageFile;
		}
	}
	///////////////////////////////////////////////////
	
	void NDSprite::SetLeftShoulderImage(const char* imageFile)
	{
		//m_leftShoulderImage = imageFile;
		if (imageFile)
		{
			m_leftShoulderImage = imageFile;
		}
	}
	
	void NDSprite::SetRightShoulderImage(const char* imageFile)
	{
		//m_rightShoulderImage= imageFile;
		if (imageFile)
		{
			m_rightShoulderImage = imageFile;
		}
	}
	
	void NDSprite::SetSkirtStandImage(const char* imageFile)
	{
		//m_skirtStandImage = imageFile;
		if (imageFile)
		{
			m_skirtStandImage = imageFile;
		}
	}
	
	void NDSprite::SetSkirtWalkImage(const char* imageFile)
	{
		//m_skirtWalkImage = imageFile;
		if (imageFile)
		{
			m_skirtWalkImage = imageFile;
		}
	}
	
	void NDSprite::SetSkirtSitImage(const char* imageFile)
	{
		//m_skirtSitImage = imageFile;
		if (imageFile)
		{
			m_skirtSitImage = imageFile;
		}
	}
	
	void NDSprite::SetSkirtLiftLegImage(const char* imageFile)
	{
		//m_skirtLiftLegImage = imageFile;
		if (imageFile)
		{
			m_skirtLiftLegImage = imageFile;
		}
	}
	///////////////////////////////////////////////////
	
	void NDSprite::SetDoubleHandSpearImage(const char* imageFile)
	{
		//m_doubleHandSpearImage = imageFile;
		if (imageFile)
		{
			m_doubleHandSpearImage = imageFile;
		}
	}
	
	CCTexture2D	*NDSprite::GetHairImage()
	{
		if (!m_hairImage.empty()) 
		{
			//todo(zjh)
			//return [[CCTextureCache sharedTextureCache] addColorImage:m_hairImage];			
		}
		return NULL;		
	}
	
	CCTexture2D	*NDSprite::GetFaceImage()
	{
		if (!m_faceImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->addImage(m_faceImage.c_str());
		}
		return NULL;
		
	}
	
	CCTexture2D	*NDSprite::GetExpressionImage()
	{
		if (!m_expressionImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->addImage(m_expressionImage.c_str());
		}
		return NULL;
	}
	
	CCTexture2D	*NDSprite::GetCapImage()
	{
		if (!m_capImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->addImage(m_capImage.c_str());
		}
		return NULL;
	}
	
	CCTexture2D	*NDSprite::GetArmorImage()
	{
		if (!m_armorImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->addImage(m_armorImage.c_str());			
		}
		return NULL;
	}
	
	CCTexture2D	*NDSprite::GetRightHandWeaponImage()
	{
		if (m_rightHandWeaponImage.empty() || m_weaponType != ONE_HAND_WEAPON) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->addImage(m_rightHandWeaponImage.c_str());	
	}
	
	CCTexture2D	*NDSprite::GetLeftHandWeaponImage()
	{
		if (m_leftHandWeaponImage.empty() || m_secWeaponType != ONE_HAND_WEAPON) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_leftHandWeaponImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandWeaponImage()
	{
		if (m_doubleHandWeaponImage.empty() || m_weaponType != TWO_HAND_WEAPON) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_doubleHandWeaponImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetDualSwordImage()
	{
		if (m_dualSwordImage.empty() || m_weaponType != DUAL_SWORD) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_dualSwordImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetDualKnifeImage()
	{
		if (m_dualKnifeImage.empty() || m_weaponType != DUAL_KNIFE) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_dualKnifeImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandWandImage()
	{
		if (m_doubleHandWandImage.empty() || m_weaponType != TWO_HAND_WAND) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_doubleHandWandImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandBowImage()
	{
		if (m_doubleHandBowImage.empty() || m_weaponType != TWO_HAND_BOW) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_doubleHandBowImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetShieldImage()
	{
		if (m_shieldImage.empty() || m_secWeaponType != SEC_SHIELD) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_shieldImage.c_str());
	}
	
	CCTexture2D	*NDSprite::GetFaqiImage()
	{
		if (m_faqiImage.empty() || m_secWeaponType != SEC_FAQI) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_faqiImage.c_str());
	}
	
	CCTexture2D *NDSprite::GetCloakImage()
	{
		if (!m_cloakImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_cloakImage.c_str());		
		}
		return NULL;
	}
	
	CCTexture2D *NDSprite::GetLeftShoulderImage()
	{
		if (!m_leftShoulderImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_leftShoulderImage.c_str());			
		}
		return NULL;
		
	}
	
	CCTexture2D *NDSprite::GetRightShoulderImage()
	{
		if (!m_rightShoulderImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_rightShoulderImage.c_str());			
		}
		return NULL;
	}
	
	CCTexture2D *NDSprite::GetSkirtStandImage()
	{
		if (!m_skirtStandImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_skirtStandImage.c_str());			
		}
		return NULL;
	}
	
	CCTexture2D *NDSprite::GetSkirtWalkImage()
	{
		if (!m_skirtWalkImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_skirtWalkImage.c_str());			
		}
		return NULL;
		
	}
	
	CCTexture2D *NDSprite::GetSkirtSitImage()
	{
		if (!m_skirtSitImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_skirtSitImage.c_str());			
		}
		return NULL;
	}
	
	CCTexture2D *NDSprite::GetSkirtLiftLegImage()
	{
		if (!m_skirtLiftLegImage.empty()) 
		{
			return CCTextureCache::sharedTextureCache()->
				addImage(m_skirtLiftLegImage.c_str());			
		}
		return NULL;		
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandSpearImage()
	{
		if (m_doubleHandSpearImage.empty() || m_weaponType != TWO_HAND_SPEAR) 
		{
			return NULL;
		}
		return CCTextureCache::sharedTextureCache()->
			addImage(m_doubleHandSpearImage.c_str());
	}
	
// 	CCTexture2D* NDSprite::getColorTexture(int imageIndex, NDAnimationGroup* animationGroup)
// 	{
// 		CCTexture2D* tex = NULL;
// 		// colorinfo特殊处理
// 		if ( animationGroup && this->colorInfo != -1 ) 
// 		{
// 			if (!colorInfoImage) 
// 			{
// //				stringstream ss;
// //				ss << [[animationGroup.images objectAtIndex:imageIndex] UTF8String]
// //				<< "@" << this->colorInfo;
// 				colorInfoImage = [[NSString stringWithFormat:@"%@@%d", [animationGroup.images objectAtIndex:imageIndex], this->colorInfo] retain];
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
	
	CCTexture2D* NDSprite::getNpcLookfaceTexture(int imageIndex, NDAnimationGroup* animationGroup)
	{
		CCTexture2D* tex = NULL;
		if (!animationGroup)
		{
			return NULL;
		}
		std::vector<std::string>* vImg = animationGroup->getImages();
		if (npcLookface == -1 && vImg && vImg->size() > imageIndex)  //非普通NPC 
		{
			tex = CCTextureCache::sharedTextureCache()->
				addImage((*vImg)[imageIndex].c_str());
		}
		return tex;
	}
	
	int NDSprite::GetHeight()
	{
		return m_currentAnimation->getH();
	}
	
	int NDSprite::GetWidth()
	{
		return m_currentAnimation->getW();
	}
	
	int NDSprite::getGravityY()
	{
		if (m_currentAnimation == NULL || 0 == m_currentAnimation->getBottomY()) 
		{
			return 0;
		}
		
		return m_currentAnimation->getBottomY() - m_currentAnimation->getY();
	}
	
	int NDSprite::getGravityX()
	{
		if (m_currentAnimation == NULL || 0 == m_currentAnimation->getMidX()) 
		{
			return 0;
		}
		return m_currentAnimation->getMidX() - m_currentAnimation->getX();
	}
	
	bool NDSprite::GetLastPointOfPath(CGPoint& pos)
	{
		size_t count = m_pointList.size();
		
		if (count == 0)
			return false;
			
		pos = m_pointList[count - 1];
		
		return true;
	}
	
	void NDSprite::SetPlayFrameRange(int nStartFrame, int nEndFrame)
	{
		if (m_frameRunRecord)
		{
			m_frameRunRecord->SetPlayRange(nStartFrame, nEndFrame);
		}
	}
	
	void NDSprite::SetHightLight(bool bSet)
	{
		m_bHightLight = bSet;
	}

	NDFrame* NDSprite::GetCurrentFrame()
	{
		NDFrame *frame = m_currentAnimation->getFrames()->
			getObjectAtIndex(m_frameRunRecord->getCurrentFrameIndex());
		return frame;
	}

	cocos2d::CCTexture2D* NDSprite::getColorTexture( int imageIndex,
		NDAnimationGroup* animationGroup )
	{
		CCTexture2D* pkTex = 0;
		NDPicture* pkPic = 0;

		if (animationGroup && 1 != colorInfo)
		{
			if (0 == colorInfoImage.length())
			{
				std::vector<std::string>* pkVector = animationGroup->getImages();
				colorInfoImage = (*pkVector)[imageIndex];
			}

			int nPos = colorInfoImage.find_first_of("./");

			if (-1 != nPos)
			{
				colorInfoImage = colorInfoImage.substr(nPos + 2,colorInfoImage.length());
			}

			for (std::string::iterator it = colorInfoImage.begin();
				it != colorInfoImage.end();it++)
			{
				if (*it == '/')
				{
					*it = '\\';
				}
			}

			pkPic = NDPicturePool::DefaultPool()->AddPicture(colorInfoImage.c_str());

			if (0 == pkPic)
			{
				return 0;
			}

			pkTex = pkPic->GetTexture();
		}

		return pkTex;
	}
}