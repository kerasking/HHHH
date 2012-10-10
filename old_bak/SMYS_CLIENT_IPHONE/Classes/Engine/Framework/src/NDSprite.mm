//
//  NDSprite.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDSprite.h"
#import "CCTextureCache.h"
#import "CCTextureCacheExt.h"
#import "NDPath.h"
#import "NDAnimationGroupPool.h"
#import "NDLayer.h"
#import "NDFrame.h"
#import "NDAnimationGroup.h"
#import "NDMapLayer.h"
#import "NDAutoPath.h"
#import "NDConstant.h"
#import "NDMonster.h"
#import "CGPointExtension.h"
#import "NDPlayer.h"
#import "NDRidePet.h"
#include "Fighter.h"
#import "NDDirector.h"
#include "BattleMgr.h"
#include "Battle.h"
#include "NDLightEffect.h"
#include "NDMapMgr.h"
#include "GameScene.h"
#include "cpLog.h"
#include <sstream>

namespace NDEngine
{
	IMPLEMENT_CLASS(NDSprite, NDNode)
	
	NDSprite::NDSprite()
	{
		m_aniGroup = nil;
		m_currentAnimation = nil;
		m_frameRunRecord = nil;
		m_reverse = false;
		m_moveMap = false;
		m_moving  = false;
		m_movePathIndex = 0;

//		NDLog(@"init pos");
		m_position.x = 0;
		m_position.y = 0;
		
		cloak = -1;
		colorInfo = -1;
		npcLookface = -1;
		
		m_iSpeed = 4;
		m_targetPos  = CGPointZero;
		
		m_aniGroup = nil;
		
		m_picSprite = NULL;
		
		m_rectSprite = CGRectZero;
		
		m_bNonRole = false;
		
		//set images
		m_hairImage = m_faceImage = m_expressionImage = m_capImage = m_armorImage = m_rightHandWeaponImage = m_leftHandWeaponImage = nil;
		m_doubleHandWeaponImage = m_dualSwordImage = m_dualKnifeImage = m_doubleHandWandImage = m_doubleHandBowImage = m_shieldImage = nil;
		m_faqiImage = m_cloakImage = m_doubleHandSpearImage = m_leftShoulderImage = m_rightShoulderImage = m_skirtStandImage = m_skirtWalkImage = nil;
		m_skirtSitImage = m_skirtLiftLegImage = colorInfoImage = nil;
		
		m_weaponType = m_secWeaponType = m_weaponQuality = m_secWeaponQuality = m_capQuality = m_armorQuality = m_cloakQuality = 0;
		
		m_faceRight = true;
		scale = 1.0f;
		
		m_bHightLight = false;
	}
	
	NDSprite::~NDSprite()
	{	
		[m_aniGroup release];
		[m_frameRunRecord release];
	}
	
	void NDSprite::Initialization(const char* sprFile)
	{
		NDNode::Initialization();	
		m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:[NSString stringWithUTF8String:sprFile]];		
	}
	
	void NDSprite::SetCurrentAnimation(int animationIndex, bool reverse)
	{
		//NDLog(@"animationIndex%d",animationIndex);
		if (m_aniGroup) 
		{
			if (animationIndex < 0 || animationIndex >= (int)[m_aniGroup.animations count]) 
			{
				return;
			}
		
			m_reverse = reverse;
			
			if (m_currentAnimation == nil ||
			    m_currentAnimation.type == ANIMATION_TYPE_ONCE_END ||
			    m_currentAnimation.type == ANIMATION_TYPE_ONCE_START ||
			    this->m_currentAnimation.curIndexInAniGroup != animationIndex) 
			{
				m_currentAnimation = [m_aniGroup.animations objectAtIndex:animationIndex];
				m_currentAnimation.curIndexInAniGroup = animationIndex;
				[m_frameRunRecord release];
				m_frameRunRecord = nil;
				m_frameRunRecord = [[NDFrameRunRecord alloc] init];		
			}
			
			this->SetContentSize(CGSizeMake(m_currentAnimation.w, m_currentAnimation.h));
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
							this->OnMoveBegin();
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
			
			[m_aniGroup setRuningSprite:this];
			m_aniGroup.runningMapSize = node->GetContentSize();
			m_aniGroup.position = m_position;
	
			m_currentAnimation.reverse = m_reverse;
			
			bool oldTitleHightLight = IsTileHightLight();
			TileSetHightLight(m_bHightLight);
			
			bool bRet = OnDrawBegin(bDraw);
			if (bRet) [m_currentAnimation runWithRunFrameRecord:m_frameRunRecord draw:bDraw scale:scale];				
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
			if (this->GetParent()) 
			{
				NDNode* layer = this->GetParent();
				if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
				{
					bool bRet = OnDrawBegin(bDraw);
					if (bDraw && bRet)
					{
						CGSize sizemap = layer->GetContentSize();
						CGSize size = m_picSprite->GetSize();
						m_picSprite->DrawInRect(CGRectMake(GetPosition().x, GetPosition().y+320-sizemap.height, size.width, size.height));
					}
					OnDrawEnd(bDraw);
				}
			}
		}
	}
	
	void NDSprite::SetPosition(CGPoint newPosition)
	{
//		NDLog(@"new pos:%f,%f",newPosition.x, newPosition.y);
		this->m_position = CGPointMake(newPosition.x, newPosition.y);
	}
	
	void NDSprite::MoveToPosition(std::vector<CGPoint> toPos, SpriteSpeed speed, bool moveMap, bool ignoreMask/*=false*/, bool mustArrive/*=false*/)
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
				for (int i =0; i < iSize; i++) 
				{
					CGPoint to = toPos[i];
					std::vector<CGPoint> pointlist;
					NDAutoPath::sharedAutoPath()->autoFindPath(from, to, (NDMapLayer*)layer, m_iSpeed, mustArrive, ignoreMask);
					pointlist = NDAutoPath::sharedAutoPath()->getPathPointVetor();
					
					if (!pointlist.empty()) 
					{
						m_pointList.insert(m_pointList.end(), pointlist.begin(), pointlist.end());
						from = m_pointList[m_pointList.size()-1];
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
	
	void NDSprite::SetSprite(NDPicture* pic)
	{
		m_picSprite = pic;
		if (pic)
		{
			CGPoint point = this->GetPosition();
			CGSize size = pic->GetSize();
			m_rectSprite = CGRectMake(point.x, point.y, size.width, size.height);
		}
	}
	
	bool NDSprite::IsAnimationComplete()
	{
		return m_currentAnimation == NULL ? true : m_frameRunRecord.isCompleted;
	}
	
	void NDSprite::RunBattleSubAnimation(Fighter* f)
	{
		Battle* battle = BattleMgrObj.GetBattle();
		if (!battle) {
			return;
		}
		
		// 1.获取当前帧
		NDFrame* curFrame = [m_currentAnimation.frames objectAtIndex:m_frameRunRecord.currentFrameIndex];
		
		// 2.取当前帧的子动画数组并加入战斗对象的子动画数组
		if (curFrame && curFrame.subAnimationGroups) {
			for (NSUInteger i = 0; i < [curFrame.subAnimationGroups count]; i++) {
				NDAnimationGroup *group = [curFrame.subAnimationGroups objectAtIndex:i];
				group.reverse = f->m_info.group == BATTLE_GROUP_DEFENCE ? false : true;
				
				if (group.identifer == 0) { // 非魔法特效
					if (group.type == SUB_ANI_TYPE_SELF || group.type == SUB_ANI_TYPE_NONE) {
						battle->addSubAniGroup(this, group, f);
					}
				} else { // 魔法特效
					if (group.identifer == f->getUseSkill()->getSubAniID()) {
						if (group.type == SUB_ANI_TYPE_SELF) {
							battle->addSubAniGroup(this, group, f);
						} else if (group.type == SUB_ANI_TYPE_TARGET) {
							
							VEC_FIGHTER& array = f->getArrayTarget();
							if (array.size() == 0) { // 如果没有目标数组，则制定目标为mainTarget
								battle->addSubAniGroup(this, group, f->m_mainTarget);
							} else {
								for (size_t j = 0; j < array.size(); j++) {
									battle->addSubAniGroup(this, group, array.at(j));
								}
							}
						} else if (group.type == SUB_ANI_TYPE_NONE) {							
							battle->addSubAniGroup(this, group, f);
						}
					}
				}
			}
		}
	}
	
	int NDSprite::GetCurFrameIndex()
	{
		return m_frameRunRecord == NULL ? 0 : m_frameRunRecord.currentFrameIndex;
	}
	
	bool NDSprite::DrawSubAnimation(NDSubAniGroup& sag)
	{
		NDNode* layer = this->GetParent();
		
		if (!layer)
		{
			return true;
		}
		
		NDFrameRunRecord* record = sag.frameRec;
		
		if (!record) 
		{
			return true;
		}
		
		NDAnimationGroup *aniGroup = sag.aniGroup;
		
		if(!aniGroup) {
			return true;
		}
		
		CGPoint pos = aniGroup.position;
		aniGroup.runningMapSize = layer->GetContentSize();
		
		NDAnimation* ani = nil;
		if ([aniGroup.animations count] > 0) {
			ani = [aniGroup.animations objectAtIndex:0];
		}
		
		if (!ani) {
			return true;
		}
		
		CGPoint posTarget = ccp(0, 0);
		if (aniGroup.type == SUB_ANI_TYPE_NONE) {
			aniGroup.reverse = sag.fighter->m_info.group == BATTLE_GROUP_DEFENCE ? false : true;
			int coordx = 0;
			
			if (aniGroup.reverse) {// 向右释放技能
				coordx += (240 - (aniGroup.position.x + ani.w)) * 2;
			}
			
			posTarget.x = pos.x + ani.w / 2 + coordx + 20;
			posTarget.y = pos.y + ani.h / 2 + 45;
			//aniGroup.draw(g, pos.x + aniGroup.getWidth() / 2 + coordx, pos.y + aniGroup.getHeight() + coordy, 0, 0);
		} else if (aniGroup.type == SUB_ANI_TYPE_TARGET || aniGroup.type == SUB_ANI_TYPE_SELF) {
			posTarget.x = sag.fighter->getX();
			posTarget.y = sag.fighter->getY();
			//aniGroup.draw(g, sag.fighter.getX(), sag.fighter.getY(), 0, 0);
		}
		
		// 子动画播放位置设置
		aniGroup.position = posTarget;
		
		[ani runWithRunFrameRecord:record draw:true scale:scale];
		
		aniGroup.position = pos;
		
		return record.currentFrameIndex != 0 && record.nextFrameIndex == 0;
	}
	
	void NDSprite::SetNormalAniGroup(int lookface)
	{
		if (lookface <= 0) {
			return;
		}
		
//		colorInfo = lookface / 100000 % 10;
//		
//		if (colorInfo == 0)	colorInfo = -1;
		
		Initialization( [[NSString stringWithFormat:@"%@model_%d%s", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()], lookface/1000000, ".spr"] UTF8String] );
		
		m_faceRight = true;
		SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
	}
		
	CGRect NDSprite::GetSpriteRect()
	{
		if (m_currentAnimation) 
		{
			m_aniGroup.position = m_position;
			return [m_currentAnimation getRect];
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
			[m_hairImage release];
			m_hairImage = [[NSString stringWithFormat:@"%@@%d", [NSString stringWithUTF8String:imageFile], colorIndex -1] retain];
			[[CCTextureCache sharedTextureCache] addColorImage:m_hairImage];
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
			[m_faceImage release];
			m_faceImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetExpressionImage(const char* imageFile)
	{
		//m_expressionImage = imageFile;
		if (imageFile)
		{
			[m_expressionImage release];
			m_expressionImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetCapImage(const char* imageFile)
	{
		//m_capImage = imageFile;
		if (imageFile)
		{
			[m_capImage release];
			m_capImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetArmorImage(const char* imageFile)
	{
		//m_armorImage = imageFile;
		if (imageFile)
		{
			[m_armorImage release];
			m_armorImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetRightHandWeaponImage(const char* imageFile)
	{
		//m_rightHandWeaponImage = imageFile;
		if (imageFile)
		{
			[m_rightHandWeaponImage release];
			m_rightHandWeaponImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetLeftHandWeaponImage(const char* imageFile)
	{
		//m_leftHandWeaponImage = imageFile;
		if (imageFile)
		{
			[m_leftHandWeaponImage release];
			m_leftHandWeaponImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetDoubleHandWeaponImage(const char* imageFile)
	{
		//m_doubleHandWeaponImage = imageFile;
		if (imageFile)
		{
			[m_doubleHandWeaponImage release];
			m_doubleHandWeaponImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetDualSwordImage(const char* imageFile)
	{
		//m_dualSwordImage = imageFile;
		if (imageFile)
		{
			[m_dualSwordImage release];
			m_dualSwordImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetDualKnifeImage(const char* imageFile)
	{
		//m_dualKnifeImage = imageFile;
		if (imageFile)
		{
			[m_dualKnifeImage release];
			m_dualKnifeImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetDoubleHandWandImage(const char* imageFile)
	{
		//m_doubleHandWandImage = imageFile;
		if (imageFile)
		{
			[m_doubleHandWandImage release];
			m_doubleHandWandImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetDoubleHandBowImage(const char* imageFile)
	{
		//m_doubleHandBowImage = imageFile;
		if (imageFile)
		{
			[m_doubleHandBowImage release];
			m_doubleHandBowImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetShieldImage(const char* imageFile)
	{
		//m_shieldImage = imageFile;
		if (imageFile)
		{
			[m_shieldImage release];
			m_shieldImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetFaqiImage(const char* imageFile)
	{
		//m_faqiImage = imageFile;
		if (imageFile)
		{
			[m_faqiImage release];
			m_faqiImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetCloakImage(const char* imageFile)
	{
		//m_cloakImage = imageFile;
		if (imageFile)
		{
			[m_cloakImage release];
			m_cloakImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	///////////////////////////////////////////////////
	
	void NDSprite::SetLeftShoulderImage(const char* imageFile)
	{
		//m_leftShoulderImage = imageFile;
		if (imageFile)
		{
			[m_leftShoulderImage release];
			m_leftShoulderImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetRightShoulderImage(const char* imageFile)
	{
		//m_rightShoulderImage= imageFile;
		if (imageFile)
		{
			[m_rightShoulderImage release];
			m_rightShoulderImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetSkirtStandImage(const char* imageFile)
	{
		//m_skirtStandImage = imageFile;
		if (imageFile)
		{
			[m_skirtStandImage release];
			m_skirtStandImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetSkirtWalkImage(const char* imageFile)
	{
		//m_skirtWalkImage = imageFile;
		if (imageFile)
		{
			[m_skirtWalkImage release];
			m_skirtWalkImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetSkirtSitImage(const char* imageFile)
	{
		//m_skirtSitImage = imageFile;
		if (imageFile)
		{
			[m_skirtSitImage release];
			m_skirtSitImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	void NDSprite::SetSkirtLiftLegImage(const char* imageFile)
	{
		//m_skirtLiftLegImage = imageFile;
		if (imageFile)
		{
			[m_skirtLiftLegImage release];
			m_skirtLiftLegImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	///////////////////////////////////////////////////
	
	void NDSprite::SetDoubleHandSpearImage(const char* imageFile)
	{
		//m_doubleHandSpearImage = imageFile;
		if (imageFile)
		{
			[m_doubleHandSpearImage release];
			m_doubleHandSpearImage = [[NSString stringWithUTF8String:imageFile] retain];
		}
	}
	
	CCTexture2D	*NDSprite::GetHairImage()
	{
		if (m_hairImage && ![m_hairImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addColorImage:m_hairImage];			
		}
		return nil;		
	}
	
	CCTexture2D	*NDSprite::GetFaceImage()
	{
		if (m_faceImage  && ![m_faceImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_faceImage];
		}
		return nil;
		
	}
	
	CCTexture2D	*NDSprite::GetExpressionImage()
	{
		if (m_expressionImage && ![m_expressionImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_expressionImage];
		}
		return nil;
	}
	
	CCTexture2D	*NDSprite::GetCapImage()
	{
		if (m_capImage && ![m_capImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_capImage];
		}
		return nil;
	}
	
	CCTexture2D	*NDSprite::GetArmorImage()
	{
		if (m_armorImage && ![m_armorImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_armorImage];			
		}
		return nil;
	}
	
	CCTexture2D	*NDSprite::GetRightHandWeaponImage()
	{
		if (!m_rightHandWeaponImage || m_weaponType != ONE_HAND_WEAPON || [m_rightHandWeaponImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_rightHandWeaponImage];
	}
	
	CCTexture2D	*NDSprite::GetLeftHandWeaponImage()
	{
		if (!m_leftHandWeaponImage || m_secWeaponType != ONE_HAND_WEAPON || [m_leftHandWeaponImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_leftHandWeaponImage];
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandWeaponImage()
	{
		if (!m_doubleHandWeaponImage || m_weaponType != TWO_HAND_WEAPON || [m_doubleHandWeaponImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_doubleHandWeaponImage];
	}
	
	CCTexture2D	*NDSprite::GetDualSwordImage()
	{
		if (!m_dualSwordImage || m_weaponType != DUAL_SWORD || [m_dualSwordImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_dualSwordImage];
	}
	
	CCTexture2D	*NDSprite::GetDualKnifeImage()
	{
		if (!m_dualKnifeImage || m_weaponType != DUAL_KNIFE || [m_dualKnifeImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_dualKnifeImage];
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandWandImage()
	{
		if (!m_doubleHandWandImage || m_weaponType != TWO_HAND_WAND || [m_doubleHandWandImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_doubleHandWandImage];
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandBowImage()
	{
		if (!m_doubleHandBowImage || m_weaponType != TWO_HAND_BOW || [m_doubleHandBowImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_doubleHandBowImage];
	}
	
	CCTexture2D	*NDSprite::GetShieldImage()
	{
		if (!m_shieldImage || m_secWeaponType != SEC_SHIELD || [m_shieldImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_shieldImage];
	}
	
	CCTexture2D	*NDSprite::GetFaqiImage()
	{
		if (!m_faqiImage || m_secWeaponType != SEC_FAQI || [m_faqiImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_faqiImage];
	}
	
	CCTexture2D *NDSprite::GetCloakImage()
	{
		if (m_cloakImage && ![m_cloakImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_cloakImage];			
		}
		return nil;
		
	}
	
	CCTexture2D *NDSprite::GetLeftShoulderImage()
	{
		if (m_leftShoulderImage && ![m_leftShoulderImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_leftShoulderImage];			
		}
		return nil;
		
	}
	
	CCTexture2D *NDSprite::GetRightShoulderImage()
	{
		if (m_rightShoulderImage && ![m_rightShoulderImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_rightShoulderImage];			
		}
		return nil;
	}
	
	CCTexture2D *NDSprite::GetSkirtStandImage()
	{
		if (m_skirtStandImage && ![m_skirtStandImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_skirtStandImage];			
		}
		return nil;
	}
	
	CCTexture2D *NDSprite::GetSkirtWalkImage()
	{
		if (m_skirtWalkImage && ![m_skirtWalkImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_skirtWalkImage];			
		}
		return nil;
		
	}
	
	CCTexture2D *NDSprite::GetSkirtSitImage()
	{
		if (m_skirtSitImage && ![m_skirtSitImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_skirtSitImage];			
		}
		return nil;
	}
	
	CCTexture2D *NDSprite::GetSkirtLiftLegImage()
	{
		if (m_skirtLiftLegImage && ![m_skirtLiftLegImage isEqualToString:@""]) 
		{
			return [[CCTextureCache sharedTextureCache] addImage:m_skirtLiftLegImage];			
		}
		return nil;		
	}
	
	CCTexture2D	*NDSprite::GetDoubleHandSpearImage()
	{
		if (!m_doubleHandSpearImage || m_weaponType != TWO_HAND_SPEAR  || [m_doubleHandSpearImage isEqualToString:@""]) 
		{
			return nil;
		}
		return [[CCTextureCache sharedTextureCache] addImage:m_doubleHandSpearImage];
	}
	
	CCTexture2D* NDSprite::getColorTexture(int imageIndex, NDAnimationGroup* animationGroup)
	{
		CCTexture2D* tex = NULL;
		// colorinfo特殊处理
		if ( animationGroup && this->colorInfo != -1 ) 
		{
			if (!colorInfoImage) 
			{
//				stringstream ss;
//				ss << [[animationGroup.images objectAtIndex:imageIndex] UTF8String]
//				<< "@" << this->colorInfo;
				colorInfoImage = [[NSString stringWithFormat:@"%@@%d", [animationGroup.images objectAtIndex:imageIndex], this->colorInfo] retain];
			}
			
			tex = [[CCTextureCache sharedTextureCache] addColorImage:colorInfoImage];
			
			if (!tex)
			{
				[colorInfoImage release];
				colorInfoImage = [[animationGroup.images objectAtIndex:imageIndex] retain];
				tex = [[CCTextureCache sharedTextureCache] addImage:colorInfoImage];
			}
			
		}	
		return tex;
	}
	
	CCTexture2D* NDSprite::getNpcLookfaceTexture(int imageIndex, NDAnimationGroup* animationGroup)
	{
		CCTexture2D* tex = NULL;
		
		if ( animationGroup && npcLookface == -1 )  //非普通NPC 
		{
			tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
		}
		return tex;
	}
	
	int NDSprite::GetHeight()
	{
		return m_currentAnimation.h;
	}
	
	int NDSprite::GetWidth()
	{
		return m_currentAnimation.w;
	}
	
	int NDSprite::getGravityY()
	{
		if (m_currentAnimation == nil || 0 == m_currentAnimation.bottomY) 
		{
			return 0;
		}
		
		return m_currentAnimation.bottomY - m_currentAnimation.y;
	}
	
	int NDSprite::getGravityX()
	{
		if (m_currentAnimation == nil || 0 == m_currentAnimation.midX) 
		{
			return 0;
		}
		return m_currentAnimation.midX - m_currentAnimation.x;
	}
	
	void NDSprite::AddSubAniGroup(NDSubAniGroupEx& group)
	{
		if (group.anifile.empty()) 
		{
			return;
		}
		
		GameScene* scene = (GameScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
		if (!scene) {
			return;
		}
		
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(scene);
		if (!layer)
		{
			return;
		}	
		
		NDLightEffect* lightEffect = new NDLightEffect();
		
		std::string sprFullPath = NDPath::GetAnimationPath();
		sprFullPath.append(group.anifile);
		lightEffect->Initialization(sprFullPath.c_str());
		
		lightEffect->SetLightId(0, false);
		
		if (group.type== SUB_ANI_TYPE_NONE) 
		{
			lightEffect->SetPosition(ccp(group.coordW, group.coordH));
		} else if (group.type == SUB_ANI_TYPE_SELF) {
			lightEffect->SetPosition(ccp(group.coordW+group.x, group.coordH+group.y));
		}
		else if (group.type== SUB_ANI_TYPE_SCREEN_CENTER) 
		{
			lightEffect->SetPosition(ccpAdd(layer->GetScreenCenter(), ccp(group.coordW, group.coordH)));
		}

		
		layer->AddChild(lightEffect);
	}
	
	bool NDSprite::GetLastPointOfPath(CGPoint& pos)
	{
		size_t count = m_pointList.size();
		
		if (count == 0)
			return false;
			
		pos = m_pointList[count-1];
		
		return true;
	}
	
	void NDSprite::SetPlayFrameRange(int nStartFrame, int nEndFrame)
	{
		if (m_frameRunRecord)
		{
			[m_frameRunRecord SetPlayRange:nStartFrame EndAt:nEndFrame];
		}
	}
	
	void NDSprite::SetHightLight(bool bSet)
	{
		m_bHightLight = bSet;
	}
}




