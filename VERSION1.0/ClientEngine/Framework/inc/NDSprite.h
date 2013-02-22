//
//  NDSprite.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-11.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef __NDSprite_H
#define __NDSprite_H

#include "NDNode.h"
#include <string>
#include <vector>
#include "CCTexture2D.h"
#include "NDAnimation.h"

#include "NDPicture.h"
// #include "basedefine.h"
// #include "NDConstant.h"
#include "NDDirector.h"

#include "NDFrame.h"
#include "define.h"
#include "NDConstant.h"
#include "NDBaseFighter.h"
#include "platform.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "BaseType.h"
#include "TQPlatform.h"
#import <Foundation/Foundation.h>
#endif

#define FIGHTER_HEIGHT	70 * RESOURCE_SCALE
#define FIGHTER_WIDTH	45 * RESOURCE_SCALE

class NDAnimationGroup;
class NDSPrite;
class Fighter;

NS_NDENGINE_BGN

#define		WEAPON_NONE				0
#define		ONE_HAND_WEAPON			6
#define		TWO_HAND_WEAPON			5
#define		DUAL_SWORD				1
#define		TWO_HAND_KNIFE			4
#define		DUAL_KNIFE				8
#define		TWO_HAND_WAND			3
#define		TWO_HAND_BOW			2
#define		TWO_HAND_SPEAR			7
#define		SEC_SHIELD				9
#define		SEC_FAQI				10

	typedef enum
	{
		SpriteSexNone,
		SpriteSexMale,
		SpriteSexFemale,
		SpriteSexDynamic
	} SpriteSex;

	typedef enum
	{
		SpriteSpeedStep4 = 8,
		SpriteSpeedStep6 = 12,
		SpriteSpeedStep8 = 16,
		SpriteSpeedStep10 = 20,
		SpriteSpeedStep12 = 24
	} SpriteSpeed;

	class NDSprite;

	enum
	{
		SUB_ANI_TYPE_SELF = 0,
		SUB_ANI_TYPE_TARGET = 1,
		SUB_ANI_TYPE_NONE = 2,
		SUB_ANI_TYPE_ROLE_FEEDPET = 3,
		SUB_ANI_TYPE_ROLE_WEAPON = 4,
		SUB_ANI_TYPE_SCREEN_CENTER = 5,
	};


class NDSubAniGroup
{
public:
	NDSubAniGroup()
	{
		memset(this, 0L, sizeof(NDSubAniGroup));
	}

	NDSprite* role;
	NDBaseFighter* fighter;
	NDAnimationGroup* aniGroup; //引用
	NDFrameRunRecord* frameRec; //引用

	OBJID idAni;
	short x;
	short y;
	bool reverse;
	short coordW;
	short coordH;
	Byte type;
	int time;	//播放次数
	int antId;	//动作ID
	bool bComplete; // 播放完成
	bool isFromOut;
	int startFrame;
	bool isCanStart;//用来控制战斗中的延迟问题
	int pos;//播放位置
};

struct NDSubAniGroupEx 
{
	short x;
	short y;

	short coordW;
	short coordH;

	Byte type;

	std::string anifile;
};

enum FACE_DIRECT
{
	FACE_DIRECT_RIGHT = 0,
	FACE_DIRECT_LEFT,
	FACE_DIRECT_UP,
	FACE_DIRECT_DOWN,
};

class ISpriteEvent
{
public:
	virtual void DisplayFrameEvent(int nCurrentAnimation, int nCurrentFrame) =0;
	virtual void DisplayCompleteEvent(int nCurrentAnimation, int nDispCount)=0;
};

//class NDEngine::NDPicture;

class NDSprite: public NDNode
{
DECLARE_CLASS(NDSprite)
public:

	NDSprite();
	~NDSprite();

public:

	static NDSprite* GetGlobalPlayerPointer(int lookface);

//		
//		函数：Initialization
//		作用：初始化精灵，必须被显示或隐式调用
//		参数：sprFile动画文件，每一个精灵需要与一个动画文件绑定
//		返回值：无
	void Initialization(const char* pszSprFile,bool bFaceRight = true);
	void Initlalization(const char* pszSprFile,ISpriteEvent* pkEvent,bool bFaceRight);
//		
//		函数：OnDrawBegin
//		作用：该方法在精灵绘制之前被框架调用
//		参数：bDraw精灵是否显示在屏幕上
//		返回值：无
	virtual bool OnDrawBegin(bool bDraw)
	{
		return true;
	}

	virtual void stopMoving(bool bResetPos = true, bool bResetTeamPos = true);
//		
//		函数：OnDrawEnd
//		作用：该方法在精灵绘制完成后被框架调用
//		参数：bDraw精灵是否显示在屏幕上
//		返回值：无
	virtual void OnDrawEnd(bool bDraw)
	{
	}
//		
//		函数：SetPosition
//		作用：设置精灵在地图上的坐标
//		参数：newPosition地图坐标
//		返回值：无
	virtual void SetPosition(CCPoint newPosition);
//		
//		函数：GetPosition
//		作用：获取精灵在地图上的坐标
//		参数：无
//		返回值：地图坐标
	CCPoint GetPosition();

	int GetCol()
	{
		int iUint = 16 * RESOURCE_SCALE_INT;
		return (m_kPosition.x - iUint/2) / iUint;
	}
	
	int GetRow()
	{
		int iUint = 16 * RESOURCE_SCALE_INT;
		return (m_kPosition.y - iUint) / iUint;
	}

	int GetCurFrameIndex();

	virtual void OnMoveTurning(bool bXTurningToY,bool bInc){}
	
//		函数：stopMoving
//		作用：停止精灵在地图上的移动，如果精灵式停止的没有任何影响
//		参数：无
//		返回值：无

	virtual void standAction(bool bStand);
//		
//		函数：GetOrder
//		作用：获取精灵的排序重心值
//		参数：无
//		返回值：排序重心值
	virtual int GetOrder();
//		
//		函数：IsAnimationComplete
//		作用：判断精灵所绑定的动画是否播放完一遍
//		参数：无
//		返回值：true是，false否
	bool IsAnimationComplete();

	virtual void RunBattleSubAnimation(NDBaseFighter* pkFighter);
	virtual bool DrawSubAnimation(NDSubAniGroup& kSag);
	virtual void SetNormalAniGroup(int nLookface);

	virtual void SetWeaponImage(int weapon_lookface);
//		函数：SetHairImage
//		作用：设置头发图片
//		参数：imageFile图片文件
//		返回值：无	
	virtual void SetHairImage(const char* imageFile, int colorIndex);
//		
//		函数：SetFaceImage
//		作用：设置面部图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetFaceImage(const char* imageFile);
//		
//		函数：SetExpressionImage
//		作用：设置表情图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetExpressionImage(const char* imageFile);
//		
//		函数：SetCapImage
//		作用：设置头盔图片
//		参数：imageFile图片文件
//		返回值：
	virtual void SetCapImage(const char* imageFile);
//		
//		函数：SetArmorImage
//		作用：设置盔甲图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetArmorImage(const char* imageFile);
//		
//		函数：SetRightHandWeaponImage
//		作用：设置右手武器图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetRightHandWeaponImage(const char* imageFile);
//		
//		函数：SetLeftHandWeaponImage
//		作用：设置左手武器图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetLeftHandWeaponImage(const char* imageFile);
//		
//		函数：SetDoubleHandWeaponImage
//		作用：设置双手武器图片
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDoubleHandWeaponImage(const char* imageFile);
//		
//		函数：SetDualSwordImage
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDualSwordImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDualKnifeImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDoubleHandWandImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDoubleHandBowImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetShieldImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetFaqiImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetCloakImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetDoubleHandSpearImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetLeftShoulderImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetRightShoulderImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetSkirtStandImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetSkirtWalkImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetSkirtSitImage(const char* imageFile);
//		
//		函数：
//		作用：
//		参数：imageFile图片文件
//		返回值：无
	virtual void SetSkirtLiftLegImage(const char* imageFile);

	void SetMoveMap(bool bSet)
	{
		m_bMoveMap = bSet;
	}

	void SetPointList(std::vector<CCPoint>& vec_point)
	{
		m_kPointList = vec_point;
		StartMoving();
	}

	void StartMoving()
	{
		m_bIsMoving = true;
		m_nMovePathIndex = 0;
	}

	void SetNonRole(bool bNonRole)
	{
		this->m_bNonRole = bNonRole;
	}

	bool IsNonRole()
	{
		return this->m_bNonRole;
	}
	bool isMoving()
	{
		return m_bIsMoving;
	}

	void SetPlayFrameRange(int nStartFrame, int nEndFrame);
	void SetHightLight(bool bSet);

	NDFrame* GetCurrentFrame();
public:

	//////////////////////////////////////////////////////////////////////

	virtual cocos2d::CCTexture2D *GetHairImage();
	virtual cocos2d::CCTexture2D *GetFaceImage();
	virtual cocos2d::CCTexture2D *GetExpressionImage();
	virtual cocos2d::CCTexture2D *GetCapImage();
	virtual cocos2d::CCTexture2D *GetArmorImage();
	virtual cocos2d::CCTexture2D *GetRightHandWeaponImage();
	virtual cocos2d::CCTexture2D *GetLeftHandWeaponImage();
	virtual cocos2d::CCTexture2D *GetDoubleHandWeaponImage();
	virtual cocos2d::CCTexture2D *GetDualSwordImage();
	virtual cocos2d::CCTexture2D *GetDualKnifeImage();
	virtual cocos2d::CCTexture2D *GetDoubleHandWandImage();
	virtual cocos2d::CCTexture2D *GetDoubleHandBowImage();
	virtual cocos2d::CCTexture2D *GetShieldImage();
	virtual cocos2d::CCTexture2D *GetFaqiImage();
	virtual cocos2d::CCTexture2D *GetCloakImage();
	virtual cocos2d::CCTexture2D *GetDoubleHandSpearImage();

	virtual cocos2d::CCTexture2D *GetLeftShoulderImage();
	virtual cocos2d::CCTexture2D *GetRightShoulderImage();
	virtual cocos2d::CCTexture2D *GetSkirtStandImage();
	virtual cocos2d::CCTexture2D *GetSkirtWalkImage();
	virtual cocos2d::CCTexture2D *GetSkirtSitImage();
	virtual cocos2d::CCTexture2D *GetSkirtLiftLegImage();

	void AddSubAniGroup(NDSubAniGroupEx& kGroup);

	int GetWidth();
	int GetHeight();

	cocos2d::CCTexture2D* getColorTexture(int imageIndex,
			NDAnimationGroup* animationGroup);
	cocos2d::CCTexture2D* getNpcLookfaceTexture(int imageIndex,
			NDAnimationGroup* animationGroup);
	cocos2d::CCTexture2D* getArmorImageByCloak()
	{
		return m_nCloak == -1 ? GetArmorImage() : NULL;
	}

	bool IsCloakEmpty()
	{
		return m_nCloak == -1 ? true : false;
	}

	virtual void BeforeRunAnimation(bool bDraw)
	{
	}

#if 1
	virtual void RunAnimation(bool bDraw);
private:
	void RunAnimation_WithFrames(bool bDraw);
	void RunAnimation_WithOnePic(bool bDraw);
	bool TickAnim();
#endif

public:

	virtual void InitializationFroLookFace(int lookface, bool bSetLookFace = true);

	CCRect GetSpriteRect();
	void SetCurrentAnimation(int nAnimationIndex, bool bReverse);

	void SetSpriteDir(int dir)
	{
		dir == 2 ? (m_bFaceRight = m_bReverse = false) : (m_bFaceRight =
							m_bReverse = true);
	}
	int getGravityY();
	int getGravityX();
	void SetScale(float s)
	{
		m_fScale = s;
	}
	float GetScale()
	{
		return m_fScale;
	}
	bool GetLastPointOfPath(CCPoint& pos);
	bool IsReverse()
	{
		return m_bReverse;
	}
	unsigned int GetAnimationAmount();

	void setExtra( const int extra ) { m_nExtra = extra; }
	int getExtra() { return m_nExtra; }

protected:

	bool MoveByPath( const bool bFirstPath = false );
	void MoveToPosition(std::vector<CCPoint> toPos, SpriteSpeed speed,
			bool moveMap, bool ignoreMask = false, bool mustArrive = false);
	virtual void OnMoveBegin();
	virtual void OnMoveEnd();
	virtual void OnMoving(bool bLastPos);
	void SetSprite(NDPicture* pic);
	void reloadAni(const char* pszSprFile);

	virtual void debugDraw();

	static NDSprite* g_pkDefaultHero;

protected:

	std::string m_strHairImage;
	std::string m_strFaceImage;
	std::string m_strExpressionImage;
	std::string m_strCapImage;
	std::string m_strArmorImage;
	std::string m_strRightHandWeaponImage;
	std::string m_strLeftHandWeaponImage;
	std::string m_strDoubleHandWeaponImage;
	std::string m_strDualSwordImage;
	std::string m_strDualKnifeImage;
	std::string m_strDoubleHandWandImage;
	std::string m_strDoubleHandBowImage;
	std::string m_strShieldImage;
	std::string m_strFaqiImage;
	std::string m_strCloakImage;
	std::string m_strDoubleHandSpearImage;
	std::string m_strLeftShoulderImage;
	std::string m_strRightShoulderImage;
	std::string m_strSkirtStandImage;
	std::string m_strSkirtWalkImage;
	std::string m_strSkirtSitImage;
	std::string m_strSkirtLiftLegImage;
	std::string m_strColorInfoImage;

	int m_nMasterWeaponType;
	int m_nSecondWeaponType;
	int m_nMasterWeaponQuality;
	int m_nSecondWeaponQuality;
	int m_nCapQuality;
	int m_nArmorQuality;
	int m_nCloakQuality;

	CCPoint m_kPosition;
	NDAnimation* m_pkCurrentAnimation;
	NDFrameRunRecord* m_pkFrameRunRecord;
	NDAnimationGroup* m_pkAniGroup;

	bool m_bReverse;
	bool m_bMoveMap;
	bool m_bIsMoving;

	int m_nMovePathIndex;
	int m_nNPCLookface;
	int m_nColorInfo;
	int m_nCloak;
	int m_nSpeed;
	struct cc_timeval m_dwLastMoveTickTime;

	std::vector<CCPoint> m_kPointList;
	CCPoint m_kTargetPos;

	bool m_bNonRole;
	float m_fScale;
public:
	bool m_bFaceRight;		// 精灵面部朝向
private:
	NDPicture* m_pkPicSprite;
	CCRect m_kRectSprite;
	bool m_bHightLight;
	ISpriteEvent* m_pkSpriteEvent;
	NSTimeInterval m_dBeginTime;
	int m_nExtra;
};

#define DefaultGlobalSprite NDSprite::GetGlobalPlayerPointer(0)

NS_NDENGINE_END

#endif
